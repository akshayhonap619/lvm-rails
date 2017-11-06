Rails.application.routes.draw do
  devise_for :users
  root 'welcome#index'

  get 'welcome/index'

  get 'assessments/student/:id', to: 'assessments#student_assesments_index', as: 'students_assessments'

  put 'students/set_tutor'
  put 'tutors/add_student'
  patch 'tutors/remove_student'
  patch 'tutors/:id/tags/update', to: 'tutors#update_tags', as: 'update_tutor_tags'
  patch 'students/:id/tags/update', to: 'students#update_tags', as: 'update_student_tags'

  get 'matches', to: 'matches#index', as: 'matches'
  get 'matches/:id', to: 'matches#show', as: 'match'

  get 'tutoring_sessions/tutor/:id', to: 'tutoring_sessions#tutor_index', as: 'tutors_tutoring_sessions'
  get 'tutoring_sessions/student/:id', to: 'tutoring_sessions#student_index', as: 'students_attendance'

  patch 'students/:id/delete', to: 'students#delete', as: 'student_delete'
  patch 'students/:id/reinstate', to: 'students#reinstate', as: 'student_reinstate'
  get 'deleted_students', to: 'students#deleted_index', as: 'deleted_students'

  patch 'tutors/:id/delete', to: 'tutors#delete', as: 'tutor_delete'
  patch 'tutors/:id/reinstate', to: 'tutors#reinstate', as: 'tutor_reinstate'
  get 'deleted_tutors', to: 'tutors#deleted_index', as: 'deleted_tutors'

  get 'users', to: 'users#index', as: 'users'
  get 'users/new', to: 'users#new', as: 'new_user'
  get 'users/:id', to: 'users#show', as: 'user'
  get 'users/:id/edit', to: 'users#edit', as: 'edit_user'
  patch 'users/:id/update', to: 'users#update', as: 'update_users'
  post 'user/admin_create', to: 'users#create', as: 'admin_users_create'

  resources :affiliates
  resources :assessments
  resources :coordinators
  resources :students
  resources :student_comments
  resources :tutors
  resources :tutor_comments
  resources :tutoring_sessions
  resources :tags
end
