import mongoose from "mongoose";

const userSchema = new mongoose.Schema({

    
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true
    },

    password: {
        type: String,
        required: true
    },

    name: {
        type: String,
        required: true,
        trim: true
    },

    createdAt: {
        type: Date,
        default: Date.now
    },

    updatedAt: {
        type: Date,
        default: Date.now
    }

},
{
    versionKey: false // elimina __v)
})

export default mongoose.model('users', userSchema);
