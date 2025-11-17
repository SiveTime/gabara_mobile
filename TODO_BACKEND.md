# TODO Backend Implementation for Gabara LMS

## Overview
This TODO list outlines the backend implementation for Gabara LMS using Supabase. The platform supports three roles: Admin, Mentor, and Student, with various features including authentication, content management, quizzes, assignments, meetings, announcements, and discussion forums.

## Database Schema Design
- [ ] Design and create database tables in Supabase
  - [ ] Users table (extends Supabase auth.users with additional fields)
  - [ ] Roles table (Admin, Mentor, Student)
  - [ ] User_roles table (many-to-many relationship)
  - [ ] Classes table
  - [ ] Subjects (mata_pelajaran) table
  - [ ] Class_subjects table (junction table)
  - [ ] Quizzes table
  - [ ] Questions table
  - [ ] Options table
  - [ ] Quiz_attempts table
  - [ ] Assignments (tugas) table
  - [ ] Assignment_submissions table
  - [ ] Meetings table
  - [ ] Announcements table
  - [ ] Discussions table
  - [ ] Discussion_replies table (nested replies)

## Authentication & Authorization
- [ ] Set up Supabase authentication
  - [ ] Configure email verification
  - [ ] Implement forgot password functionality
  - [ ] Set up Row Level Security (RLS) policies
- [ ] Role-based access control
  - [ ] Create role assignment system
  - [ ] Implement permission checks for each role
- [ ] User profile management
  - [ ] Profile update endpoints
  - [ ] Password change functionality

## User Management (Admin Features)
- [ ] CRUD operations for users
  - [ ] List all users with roles
  - [ ] Create new users
  - [ ] Update user information
  - [ ] Delete/deactivate users
  - [ ] Assign/change user roles

## Class Management
- [ ] CRUD Classes (Admin & Mentor)
  - [ ] Create class
  - [ ] Read class details
  - [ ] Update class information
  - [ ] Delete class
  - [ ] List classes (filtered by role)
- [ ] Student enrollment
  - [ ] Join class functionality
  - [ ] Leave class functionality
  - [ ] Class membership management

## Subject Management (Mata Pelajaran)
- [ ] CRUD Subjects (Admin & Mentor)
  - [ ] Create subject
  - [ ] Read subject details
  - [ ] Update subject information
  - [ ] Delete subject
  - [ ] Assign subjects to classes

## Quiz Management
- [ ] CRUD Quizzes (Admin & Mentor)
  - [ ] Create quiz with questions and options
  - [ ] Read quiz details
  - [ ] Update quiz information
  - [ ] Delete quiz
  - [ ] Set quiz availability (open/close dates)
- [ ] Quiz taking functionality (Students)
  - [ ] Start quiz attempt
  - [ ] Submit answers
  - [ ] Calculate scores
  - [ ] Track attempts and time limits

## Assignment Management (Tugas)
- [ ] CRUD Assignments (Admin & Mentor)
  - [ ] Create assignment
  - [ ] Read assignment details
  - [ ] Update assignment information
  - [ ] Delete assignment
  - [ ] Set deadlines
- [ ] Submission system (Students)
  - [ ] Submit assignment
  - [ ] Update submission
  - [ ] Track submission status

## Meeting Management
- [ ] CRUD Meetings (Admin & Mentor)
  - [ ] Create meeting
  - [ ] Read meeting details
  - [ ] Update meeting information
  - [ ] Delete meeting
  - [ ] Schedule meetings
- [ ] Meeting attendance (Students)
  - [ ] Mark attendance
  - [ ] View meeting history

## Announcement System
- [ ] CRUD Announcements (Admin)
  - [ ] Create announcement
  - [ ] Read announcements
  - [ ] Update announcement
  - [ ] Delete announcement
  - [ ] Target specific classes or all users

## Discussion Forum (Students)
- [ ] Create discussion threads
- [ ] Post replies (nested)
- [ ] Edit own posts
- [ ] Delete own posts (with time limit)
- [ ] Moderate discussions (Mentor/Admin)

## Dashboard Data
- [ ] Student dashboard data
  - [ ] Enrolled classes
  - [ ] Upcoming assignments
  - [ ] Recent quiz results
  - [ ] Unread announcements
- [ ] Mentor dashboard data
  - [ ] Managed classes
  - [ ] Student progress overview
  - [ ] Pending assignments to grade
- [ ] Admin dashboard data
  - [ ] System statistics
  - [ ] User management overview
  - [ ] Platform analytics

## API Endpoints Implementation
- [ ] Update ApiEndpoints class with all new endpoints
- [ ] Implement corresponding service classes
- [ ] Update repository implementations
- [ ] Add new use cases as needed

## Data Seeding
- [ ] Create user seeders for testing
  - [ ] Admin user
  - [ ] Mentor users
  - [ ] Student users
- [ ] Seed sample classes and subjects
- [ ] Seed sample quizzes and assignments

## Security & Validation
- [ ] Implement input validation
- [ ] Set up proper RLS policies
- [ ] Add rate limiting where necessary
- [ ] Implement data sanitization

## Testing
- [ ] Unit tests for repositories and services
- [ ] Integration tests for API endpoints
- [ ] End-to-end tests for critical flows

## Deployment & Configuration
- [ ] Set up production Supabase project
- [ ] Configure environment variables
- [ ] Set up CI/CD pipeline if needed
- [ ] Database migrations and backups

## Documentation
- [ ] API documentation
- [ ] Database schema documentation
- [ ] Setup and deployment guides
