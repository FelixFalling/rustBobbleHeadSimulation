use std::pin::Pin;
use std::time::{SystemTime, UNIX_EPOCH};

use cxx_qt_lib::QString;
use qobject::BobbleRoles;

// Physics constants
const SPRING_CONSTANT: f64 = 0.3;
const DAMPING: f64 = 0.92;
const GRAVITY: f64 = 0.2;

#[derive(Clone, Debug)]
pub struct BobbleHead {
    pub rest_x: f64,
    pub rest_y: f64,
    pub x: f64,
    pub y: f64,
    pub velocity_x: f64,
    pub velocity_y: f64,
    pub rotation: f64,
    pub rotation_velocity: f64,
    pub head_radius: f64,
    pub color: String,
}

impl BobbleHead {
    pub fn new(x: f64, y: f64, radius: f64, color: &str) -> Self {
        Self {
            rest_x: x,
            rest_y: y,
            x,
            y,
            velocity_x: 0.0,
            velocity_y: 0.0,
            rotation: 0.0,
            rotation_velocity: 0.0,
            head_radius: radius,
            color: color.to_string(),
        }
    }

    pub fn update(&mut self, delta_time: f64) {
        // Apply gravity
        self.velocity_y += GRAVITY;

        // Apply spring force to return to center
        let dx = self.rest_x - self.x;
        let dy = self.rest_y - self.y;
        self.velocity_x += dx * SPRING_CONSTANT;
        self.velocity_y += dy * SPRING_CONSTANT;

        // Apply damping
        self.velocity_x *= DAMPING;
        self.velocity_y *= DAMPING;
        self.rotation_velocity *= DAMPING * 0.95;

        // Update position
        self.x += self.velocity_x * delta_time * 60.0;
        self.y += self.velocity_y * delta_time * 60.0;

        // Coupled rotation: displacement induces rotation
        // If head moves right (positive x), it tilts left (negative rotation)
        let displacement_x = self.x - self.rest_x;
        self.rotation_velocity -= displacement_x * 0.005;

        self.rotation += self.rotation_velocity * delta_time * 60.0;

        // Platform collision (simple hardcoded floor for now, matching QML default roughly)
        // Platform at ~550 (600 - 30 - 20)
        let platform_y = 550.0;
        if self.y + self.head_radius > platform_y {
            self.y = platform_y - self.head_radius;
            self.velocity_y *= -0.5;
        }
    }

    pub fn apply_force(&mut self, force_x: f64, force_y: f64) {
        self.velocity_x += force_x * 0.5;
        self.velocity_y += force_y * 0.5;
        // Stronger initial rotation kick
        self.rotation_velocity = (force_x * 0.1).max(-1.0).min(1.0);
    }
}

#[cxx_qt::bridge]
mod qobject {
    unsafe extern "C++" {
        include!(< QAbstractListModel >);
        type QAbstractListModel;

        include!("cxx-qt-lib/qmodelindex.h");
        type QModelIndex = cxx_qt_lib::QModelIndex;

        include!("cxx-qt-lib/qvariant.h");
        type QVariant = cxx_qt_lib::QVariant;

        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;

        include!("cxx-qt-lib/qhash.h");
        type QHash_i32_QByteArray = cxx_qt_lib::QHash<cxx_qt_lib::QHashPair_i32_QByteArray>;
        
        include!("cxx-qt-lib/qpoint.h");
        type QPointF = cxx_qt_lib::QPointF;

        include!("cxx-qt-lib/qvector.h");
        type QVector_i32 = cxx_qt_lib::QVector<i32>;
    }

    #[qenum(BobbleHeadModel)]
    enum BobbleRoles {
        X,
        Y,
        RestX,
        RestY,
        Rotation,
        HeadRadius,
        Color,
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[base = QAbstractListModel]
        type BobbleHeadModel = super::BobbleHeadModelRust;

        #[cxx_override]
        #[rust_name = "row_count"]
        fn rowCount(self: &BobbleHeadModel, parent: &QModelIndex) -> i32;

        #[cxx_override]
        fn data(self: &BobbleHeadModel, index: &QModelIndex, role: i32) -> QVariant;

        #[cxx_override]
        #[rust_name = "role_names"]
        fn roleNames(self: &BobbleHeadModel) -> QHash_i32_QByteArray;

        #[qinvokable]
        fn add_bobble_head(self: Pin<&mut BobbleHeadModel>, x: f64, y: f64, radius: f64, color: &QString);

        #[qinvokable]
        fn apply_force(self: Pin<&mut BobbleHeadModel>, index: i32, force_x: f64, force_y: f64);

        #[qinvokable]
        fn set_bobble_head_position(self: Pin<&mut BobbleHeadModel>, index: i32, x: f64, y: f64);

        #[qinvokable]
        fn update_physics(self: Pin<&mut BobbleHeadModel>, delta_time: f64);

        #[inherit]
        #[rust_name = "begin_insert_rows"]
        fn beginInsertRows(self: Pin<&mut BobbleHeadModel>, parent: &QModelIndex, first: i32, last: i32);

        #[inherit]
        #[rust_name = "end_insert_rows"]
        fn endInsertRows(self: Pin<&mut BobbleHeadModel>);

        #[inherit]
        #[rust_name = "create_index"]
        fn createIndex(self: &BobbleHeadModel, row: i32, column: i32) -> QModelIndex;

        #[inherit]
        #[rust_name = "data_changed"]
        fn dataChanged(self: Pin<&mut BobbleHeadModel>, top_left: &QModelIndex, bottom_right: &QModelIndex, roles: &QVector_i32);
    }
}

pub struct BobbleHeadModelRust {
    bobble_heads: Vec<BobbleHead>,
    last_update: u64,
}

impl Default for BobbleHeadModelRust {
    fn default() -> Self {
        Self {
            bobble_heads: Vec::new(),
            last_update: SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_millis() as u64,
        }
    }
}

use cxx_qt::CxxQtType;
use qobject::*;

impl BobbleHeadModel {
    fn row_count(&self, _parent: &QModelIndex) -> i32 {
        self.bobble_heads.len() as i32
    }

    fn data(&self, index: &QModelIndex, role: i32) -> QVariant {
        let role = BobbleRoles { repr: role };

        if let Some(bobble_head) = self.bobble_heads.get(index.row() as usize) {
            match role {
                BobbleRoles::X => {
                    return QVariant::from(&bobble_head.x);
                }
                BobbleRoles::Y => {
                    return QVariant::from(&bobble_head.y);
                }
                BobbleRoles::RestX => {
                    return QVariant::from(&bobble_head.rest_x);
                }
                BobbleRoles::RestY => {
                    return QVariant::from(&bobble_head.rest_y);
                }
                BobbleRoles::Rotation => {
                    return QVariant::from(&bobble_head.rotation);
                }
                BobbleRoles::HeadRadius => {
                    return QVariant::from(&bobble_head.head_radius);
                }
                BobbleRoles::Color => {
                    return QVariant::from(&QString::from(&bobble_head.color));
                }
                _ => {}
            }
        }
        QVariant::default()
    }

    fn role_names(&self) -> QHash_i32_QByteArray {
        let mut roles = QHash_i32_QByteArray::default();
        roles.insert(BobbleRoles::X.repr, cxx_qt_lib::QByteArray::from("x"));
        roles.insert(BobbleRoles::Y.repr, cxx_qt_lib::QByteArray::from("y"));
        roles.insert(BobbleRoles::RestX.repr, cxx_qt_lib::QByteArray::from("restX"));
        roles.insert(BobbleRoles::RestY.repr, cxx_qt_lib::QByteArray::from("restY"));
        roles.insert(BobbleRoles::Rotation.repr, cxx_qt_lib::QByteArray::from("rotation"));
        roles.insert(BobbleRoles::HeadRadius.repr, cxx_qt_lib::QByteArray::from("headRadius"));
        roles.insert(BobbleRoles::Color.repr, cxx_qt_lib::QByteArray::from("color"));
        roles
    }

    fn add_bobble_head(mut self: Pin<&mut Self>, x: f64, y: f64, radius: f64, color: &QString) {
        let row = self.bobble_heads.len();
        self.as_mut().begin_insert_rows(
            &QModelIndex::default(),
            row as i32,
            row as i32,
        );
        
        self.as_mut().rust_mut().bobble_heads.push(BobbleHead::new(
            x,
            y,
            radius,
            &color.to_string(),
        ));
        
        self.as_mut().end_insert_rows();
    }

    fn apply_force(mut self: Pin<&mut Self>, index: i32, force_x: f64, force_y: f64) {
        if index >= 0 && (index as usize) < self.bobble_heads.len() {
            self.as_mut().rust_mut().bobble_heads[index as usize].apply_force(force_x, force_y);
            let model_index = self.as_ref().create_index(index, 0);
            let roles = QVector_i32::default();
            self.as_mut().data_changed(&model_index, &model_index, &roles);
        }
    }

    fn set_bobble_head_position(mut self: Pin<&mut Self>, index: i32, x: f64, y: f64) {
        if index >= 0 && (index as usize) < self.bobble_heads.len() {
            let head = &mut self.as_mut().rust_mut().bobble_heads[index as usize];
            head.x = x;
            head.y = y;
            head.velocity_x = 0.0;
            head.velocity_y = 0.0;
            let model_index = self.as_ref().create_index(index, 0);
            let roles = QVector_i32::default();
            self.as_mut().data_changed(&model_index, &model_index, &roles);
        }
    }

    fn update_physics(mut self: Pin<&mut Self>, _delta_time: f64) {
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_millis() as u64;
        
        // Limit delta time to prevent physics glitches
        let delta = ((now - self.rust().last_update) as f64).min(100.0) / 1000.0;
        
        if delta > 0.0 {
            for i in 0..self.rust().bobble_heads.len() {
                self.as_mut().rust_mut().bobble_heads[i].update(delta);
                let model_index = self.as_ref().create_index(i as i32, 0);
                let roles = QVector_i32::default();
                self.as_mut().data_changed(
                    &model_index,
                    &model_index,
                    &roles,
                );
            }
            
            self.as_mut().rust_mut().last_update = now;
        }
    }
}

// TodoList code removed

