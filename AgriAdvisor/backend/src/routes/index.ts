import { Router } from 'express';
import authRoutes from './auth.routes';
import advisoryRoutes from './advisory.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/advisory', advisoryRoutes);

export default router;