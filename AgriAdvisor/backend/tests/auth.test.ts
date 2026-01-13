import request from 'supertest';
import app from '../src/app'; // Adjust the path as necessary
import { User } from '../src/models/user.model'; // Adjust the path as necessary

describe('Authentication Tests', () => {
  beforeAll(async () => {
    await User.deleteMany({}); // Clear the database before tests
  });

  afterAll(async () => {
    await User.deleteMany({}); // Clean up after tests
  });

  it('should register a new user', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        username: 'testuser',
        password: 'testpassword',
        email: 'testuser@example.com',
      });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('token');
  });

  it('should login an existing user', async () => {
    await request(app)
      .post('/api/auth/register')
      .send({
        username: 'testuser',
        password: 'testpassword',
        email: 'testuser@example.com',
      });

    const response = await request(app)
      .post('/api/auth/login')
      .send({
        username: 'testuser',
        password: 'testpassword',
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('token');
  });

  it('should fail to login with wrong credentials', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        username: 'wronguser',
        password: 'wrongpassword',
      });

    expect(response.status).toBe(401);
    expect(response.body).toHaveProperty('message', 'Invalid credentials');
  });
});