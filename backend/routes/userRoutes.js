import express from 'express'
const route = express.Router();
import user from '../controllers/user.js'

route.post('/', user.create)
route.get('/:id', user.getOne)
route.get('/', user.getAll)
route.put('/:id',user.update)
route.delete('/:id',user.delete)

export default route;