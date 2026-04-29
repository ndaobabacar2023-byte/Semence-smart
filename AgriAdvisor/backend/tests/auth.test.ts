const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../app');
const User = require('../models/User');

beforeAll(async () => {
  await mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
});

beforeEach(async () => {
  await User.deleteMany({});
});

afterAll(async () => {
  await mongoose.connection.close();
});

describe('AUTHENTIFICATION - AgriAdvisor', () => {

  test('Inscription utilisateur', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        nom: 'Ndao',
        prenom: 'Babacar',
        email: 'babacar@test.com',
        motDePasse: '123456'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty('token');
  });

  test('Connexion utilisateur', async () => {
    await request(app)
      .post('/api/auth/register')
      .send({
        nom: 'Ndao',
        prenom: 'Babacar',
        email: 'babacar@test.com',
        motDePasse: '123456'
      });

    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'babacar@test.com',
        motDePasse: '123456'
      });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('token');
  });

  test('Échec connexion (mauvais mot de passe)', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'fake@test.com',
        motDePasse: 'wrongpass'
      });

    expect(res.statusCode).toBe(401);
  });

});
