pub mod f2 {
    pub mod users {
        pub mod v1 {
            include!("f2.users.v1.rs");
        }
    }
    pub mod errors {
        pub mod v1 {
            include!("f2.errors.v1.rs");
        }
    }
}