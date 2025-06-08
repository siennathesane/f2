use tonic::{Request, Response, Status};
use uuid::Uuid;
use crate::api::f2::users::v1::{CreateUserRequest, CreateUserResponse};
use crate::api::f2::users::v1::users_server::Users;

pub struct UserService;

#[tonic::async_trait]
impl Users for UserService {
    async fn create_user(&self, request: Request<CreateUserRequest>) -> Result<Response<CreateUserResponse>, Status> {
        let req = request.into_inner();
        println!("Received request to create user: {:?}", req);

        // Here you would typically add logic to create a user in your database
        // For now, we will just return a dummy response

        let response = CreateUserResponse {
            user: None,
            error: None,
        };

        Ok(Response::new(response))
    }
}

pub struct User {
    pub id: Uuid,
    pub handle: String,
    pub email: String,
}