import { Router } from 'express';
import { getAdvisories, createAdvisory, updateAdvisory, deleteAdvisory } from '../controllers/advisory.controller';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

// Get all advisories
router.get('/', getAdvisories);

// Create a new advisory
router.post('/', authenticate, createAdvisory);

// Update an advisory
router.put('/:id', authenticate, updateAdvisory);

// Delete an advisory
router.delete('/:id', authenticate, deleteAdvisory);

export default router;