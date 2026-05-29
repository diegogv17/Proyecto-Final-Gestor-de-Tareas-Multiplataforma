import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { TaskService, Task, CreateTaskBody, UpdateTaskBody } from './task.service';
import { CategoryService, Category } from '../categories/category.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {

  // ── Sidebar ───────────────────────────────────────────────────────
  sidebarCollapsed = true;

  // ── Usuario ───────────────────────────────────────────────────────
  userName = '';
  userId   = '';

  // ── Tareas ────────────────────────────────────────────────────────
  tasks:   Task[]     = [];
  categories: Category[] = [];
  loading  = false;
  errorMsg = '';

  // ── Filtro ────────────────────────────────────────────────────────
  activeFilter: 'TODAS' | Task['status'] = 'TODAS';

  // ── Modal crear / editar ──────────────────────────────────────────
  showModal    = false;
  editingTask: Task | null = null;
  formData: CreateTaskBody = this.emptyForm();

  // ── Modal confirmar eliminación ───────────────────────────────────
  showDeleteConfirm = false;
  taskToDelete: Task | null = null;
  deleteLoading = false;
  saving = false;

  constructor(
    private router: Router,
    private taskSvc: TaskService,
    private catSvc: CategoryService
  ) {}

  // ─────────────────────────────────────────────────────────────────
  ngOnInit(): void {
    const token = localStorage.getItem('token') ?? sessionStorage.getItem('token');
    if (!token) { this.router.navigate(['/login']); return; }
    try {
      const p = JSON.parse(atob(token.split('.')[1]));
      this.userName = p.name ?? p.email ?? 'Usuario';
      this.userId   = p.id   ?? p._id   ?? p.sub ?? '';
    } catch { this.userName = 'Usuario'; }

    this.loadCategories();
    this.loadTasks();
  }

  // ── Cargar categorías (para el select del modal) ──────────────────
  loadCategories(): void {
    this.catSvc.getCategories(this.userId).subscribe({
      next:  (res) => { this.categories = res.categories ?? []; },
      error: ()    => { /* silencioso */ }
    });
  }

  // ── Nombre de categoría por ID ────────────────────────────────────
  categoryName(id?: string): string {
    if (!id) return '—';
    return this.categories.find(c => c._id === id)?.name ?? '—';
  }

  categoryColor(id?: string): string {
    if (!id) return '#6b7280';
    return this.categories.find(c => c._id === id)?.color ?? '#6b7280';
  }

  // ── Cargar tareas ─────────────────────────────────────────────────
  loadTasks(): void {
    this.loading  = true;
    this.errorMsg = '';
    this.taskSvc.getTasks(this.userId).subscribe({
      next:  (res) => { this.tasks = res.tasks ?? []; this.loading = false; },
      error: (err) => { this.errorMsg = err.error?.error ?? 'Error al cargar tareas.'; this.loading = false; }
    });
  }

  // ── Filtros ───────────────────────────────────────────────────────
  setFilter(f: typeof this.activeFilter): void { this.activeFilter = f; }

  get filteredTasks(): Task[] {
    if (this.activeFilter === 'TODAS') return this.tasks;
    return this.tasks.filter(t => t.status === this.activeFilter);
  }

  count(status: Task['status']): number {
    return this.tasks.filter(t => t.status === status).length;
  }

  // ── Sidebar ───────────────────────────────────────────────────────
  toggleSidebar(): void { this.sidebarCollapsed = !this.sidebarCollapsed; }

  // ── Modal crear ───────────────────────────────────────────────────
  openCreateModal(): void {
    this.editingTask = null;
    this.formData    = this.emptyForm();
    this.showModal   = true;
  }

  // ── Modal editar ──────────────────────────────────────────────────
  openEditModal(task: Task): void {
    this.editingTask = task;
    this.formData = {
      title:       task.title,
      description: task.description,
      status:      task.status,
      priority:    task.priority,
      dueDate:     task.dueDate ? task.dueDate.substring(0, 10) : '',
      categoryId:  task.categoryId ?? ''
    };
    this.showModal = true;
  }

  closeModal(): void { this.showModal = false; this.editingTask = null; }

  // ── Guardar ───────────────────────────────────────────────────────
  saveTask(): void {
    if (!this.formData.title?.trim()) return;
    this.saving = true;

    if (this.editingTask) {
      const body: UpdateTaskBody = {
        title:       this.formData.title,
        description: this.formData.description,
        status:      this.formData.status,
        priority:    this.formData.priority,
        dueDate:     this.formData.dueDate     || undefined,
        categoryId:  this.formData.categoryId  || undefined
      };
      this.taskSvc.updateTask(this.editingTask._id, body).subscribe({
        next: (res) => {
          const idx = this.tasks.findIndex(t => t._id === this.editingTask!._id);
          if (idx !== -1) this.tasks[idx] = res.task;
          this.saving = false; this.closeModal();
        },
        error: (err) => { this.errorMsg = err.error?.error ?? 'Error al actualizar.'; this.saving = false; }
      });
    } else {
      const body: CreateTaskBody = {
        title:       this.formData.title,
        description: this.formData.description,
        status:      this.formData.status,
        priority:    this.formData.priority,
        dueDate:     this.formData.dueDate    || undefined,
        categoryId:  this.formData.categoryId || undefined
      };
      this.taskSvc.createTask(body).subscribe({
        next: (res) => { this.tasks.unshift(res.task); this.saving = false; this.closeModal(); },
        error: (err) => { this.errorMsg = err.error?.error ?? 'Error al crear tarea.'; this.saving = false; }
      });
    }
  }

  // ── Ciclar estado ─────────────────────────────────────────────────
  cycleStatus(task: Task): void {
    const order: Task['status'][] = ['PENDING', 'IN_PROGRESS', 'COMPLETED'];
    const next = order[(order.indexOf(task.status) + 1) % order.length];
    this.taskSvc.updateTask(task._id, { status: next }).subscribe({
      next:  (res) => { const idx = this.tasks.findIndex(t => t._id === task._id); if (idx !== -1) this.tasks[idx] = res.task; },
      error: (err) => { this.errorMsg = err.error?.error ?? 'Error al actualizar estado.'; }
    });
  }

  // ── Confirmar borrado ─────────────────────────────────────────────
  confirmDelete(task: Task): void  { this.taskToDelete = task; this.showDeleteConfirm = true; }
  cancelDelete(): void             { this.taskToDelete = null; this.showDeleteConfirm = false; }

  deleteTask(): void {
    if (!this.taskToDelete) return;
    this.deleteLoading = true;
    this.taskSvc.deleteTask(this.taskToDelete._id).subscribe({
      next: () => {
        this.tasks         = this.tasks.filter(t => t._id !== this.taskToDelete!._id);
        this.deleteLoading = false; this.cancelDelete();
      },
      error: (err) => {
        this.errorMsg      = err.error?.error ?? 'Error al eliminar.';
        this.deleteLoading = false; this.cancelDelete();
      }
    });
  }

  // ── Navegar a categorías ──────────────────────────────────────────
  goToCategories(): void { this.router.navigate(['/categories']); }

  // ── Logout ────────────────────────────────────────────────────────
  logout(): void {
    localStorage.removeItem('token');
    sessionStorage.removeItem('token');
    this.router.navigate(['/login']);
  }

  // ── Helpers ───────────────────────────────────────────────────────
  private emptyForm(): CreateTaskBody {
    return { title: '', description: '', status: 'PENDING', priority: 'MEDIUM', dueDate: '', categoryId: '' };
  }

  labelStatus(s: Task['status']): string {
    return { PENDING: 'Pendiente', IN_PROGRESS: 'En Progreso', COMPLETED: 'Completada' }[s] ?? s;
  }

  labelPriority(p: Task['priority']): string {
    return { LOW: 'Baja', MEDIUM: 'Media', HIGH: 'Alta', URGENT: 'Urgente' }[p] ?? p;
  }
}
