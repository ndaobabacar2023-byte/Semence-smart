import { Request, Response } from 'express';
import Advisory from '../models/advisory.model';

// Create a new advisory
export const createAdvisory = async (req: Request, res: Response) => {
    try {
        const advisory = new Advisory(req.body);
        await advisory.save();
        res.status(201).json(advisory);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Get all advisories
export const getAdvisories = async (req: Request, res: Response) => {
    try {
        const advisories = await Advisory.find();
        res.status(200).json(advisories);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get a specific advisory by ID
export const getAdvisoryById = async (req: Request, res: Response) => {
    try {
        const advisory = await Advisory.findById(req.params.id);
        if (!advisory) {
            return res.status(404).json({ message: 'Advisory not found' });
        }
        res.status(200).json(advisory);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update an advisory
export const updateAdvisory = async (req: Request, res: Response) => {
    try {
        const advisory = await Advisory.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!advisory) {
            return res.status(404).json({ message: 'Advisory not found' });
        }
        res.status(200).json(advisory);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Delete an advisory
export const deleteAdvisory = async (req: Request, res: Response) => {
    try {
        const advisory = await Advisory.findByIdAndDelete(req.params.id);
        if (!advisory) {
            return res.status(404).json({ message: 'Advisory not found' });
        }
        res.status(204).send();
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};