import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { CategoryService, Category, CategoryBody } from './category.service';
import { TaskService } from '../dashboard/task.service';

@Component({
  selector: 'app-categories',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './categories.component.html',
  styleUrls: ['./categories.component.css']
})
export class CategoriesComponent implements OnInit {

  // ── Usuario ───────────────────────────────────────────────────────
  userName = '';
  userId   = '';

  // ── Sidebar ───────────────────────────────────────────────────────
  sidebarCollapsed = true;

  // ── Datos ─────────────────────────────────────────────────────────
  categories: Category[] = [];
  taskCountMap: Record<string, number> = {};   // categoryId → n° tareas

  // ── Estado ────────────────────────────────────────────────────────
  loading  = false;
  errorMsg = '';
  saving   = false;
  deleteLoading = false;

  // ── Modal crear / editar ──────────────────────────────────────────
  showModal    = false;
  editingCat: Category | null = null;
  formData: CategoryBody = this.emptyForm();

  // ── Modal detalle ─────────────────────────────────────────────────
  showDetail    = false;
  detailCat: Category | null = null;
  detailTasks: any[] = [];
  detailLoading = false;

  // ── Modal confirmar borrado ───────────────────────────────────────
  showDeleteConfirm = false;
  catToDelete: Category | null = null;

  // Paleta rápida de colores
  colorPalette = [
    '#2563EB','#7C3AED','#DB2777','#DC2626',
    '#D97706','#16A34A','#0891B2','#55616d',
    '#6B7280','#1F2937','#F59E0B','#10B981'
  ];

  constructor(
    private router: Router,
    private catSvc: CategoryService,
    private taskSvc: TaskService
  ) {}

  ngOnInit(): void {
    const token = localStorage.getItem('token') ?? sessionStorage.getItem('token');
    if (!token) { this.router.navigate(['/login']); return; }
    try {
      const p = JSON.parse(atob(token.split('.')[1]));
      this.userName = p.name ?? p.email ?? 'Usuario';
      this.userId   = p.id ?? p._id ?? p.sub ?? '';
    } catch { this.userName = 'Usuario'; }

    this.loadAll();
  }

  // ── Cargar categorías + conteo de tareas ──────────────────────────
  loadAll(): void {
    this.loading = true;
    this.errorMsg = '';

    this.catSvc.getCategories(this.userId).subscribe({
      next: (res) => {
        this.categories = res.categories ?? [];
        this.loading    = false;
        this.loadTaskCounts();
      },
      error: (err) => {
        this.errorMsg = err.error?.error ?? 'Error al cargar categorías.';
        this.loading  = false;
      }
    });
  }

  // Carga tareas del usuario y cuenta por categoría
  loadTaskCounts(): void {
    this.taskSvc.getTasks(this.userId).subscribe({
      next: (res) => {
        const map: Record<string, number> = {};
        (res.tasks ?? []).forEach(t => {
          if (t.categoryId) map[t.categoryId] = (map[t.categoryId] ?? 0) + 1;
        });
        this.taskCountMap = map;
      },
      error: () => { /* silencioso */ }
    });
  }

  taskCount(catId: string): number {
    return this.taskCountMap[catId] ?? 0;
  }

  // ── Sidebar ───────────────────────────────────────────────────────
  toggleSidebar(): void { this.sidebarCollapsed = !this.sidebarCollapsed; }

  // ── Modal crear ───────────────────────────────────────────────────
  openCreate(): void {
    this.editingCat = null;
    this.formData   = this.emptyForm();
    this.showModal  = true;
  }

  // ── Modal editar ──────────────────────────────────────────────────
  openEdit(cat: Category, e: Event): void {
    e.stopPropagation();
    this.editingCat = cat;
    this.formData   = { name: cat.name, color: cat.color, icon: cat.icon ?? '' };
    this.showModal  = true;
  }

  closeModal(): void { this.showModal = false; this.editingCat = null; }

  pickColor(hex: string): void { this.formData.color = hex; }

  // ── Guardar ───────────────────────────────────────────────────────
  save(): void {
    if (!this.formData.name.trim()) return;
    this.saving = true;

    if (this.editingCat) {
      this.catSvc.updateCategory(this.editingCat._id, {
        name:  this.formData.name,
        color: this.formData.color,
        icon:  this.formData.icon
      }).subscribe({
        next: (res) => {
          const idx = this.categories.findIndex(c => c._id === this.editingCat!._id);
          if (idx !== -1) this.categories[idx] = res.category;
          this.saving = false; this.closeModal();
        },
        error: (err) => {
          this.errorMsg = err.error?.error ?? 'Error al actualizar.';
          this.saving   = false;
        }
      });
    } else {
      this.catSvc.createCategory({ ...this.formData, userId: this.userId }).subscribe({
        next: (res) => {
          this.categories.unshift(res.category);
          this.saving = false; this.closeModal();
        },
        error: (err) => {
          this.errorMsg = err.error?.error ?? 'Error al crear categoría.';
          this.saving   = false;
        }
      });
    }
  }

  // ── Ver detalle ───────────────────────────────────────────────────
  openDetail(cat: Category): void {
    this.detailCat     = cat;
    this.detailTasks   = [];
    this.showDetail    = true;
    this.detailLoading = true;

    this.catSvc.getCategoryById(cat._id).subscribe({
      next: (res) => {
        this.detailTasks   = res.tasks ?? [];
        this.detailLoading = false;
      },
      error: () => { this.detailLoading = false; }
    });
  }

  closeDetail(): void { this.showDetail = false; this.detailCat = null; }

  // ── Confirmar borrado ─────────────────────────────────────────────
  confirmDelete(cat: Category, e: Event): void {
    e.stopPropagation();
    this.catToDelete      = cat;
    this.showDeleteConfirm = true;
  }

  cancelDelete(): void { this.catToDelete = null; this.showDeleteConfirm = false; }

  deleteCategory(): void {
    if (!this.catToDelete) return;
    this.deleteLoading = true;
    this.catSvc.deleteCategory(this.catToDelete._id).subscribe({
      next: () => {
        this.categories    = this.categories.filter(c => c._id !== this.catToDelete!._id);
        this.deleteLoading = false;
        this.cancelDelete();
      },
      error: (err) => {
        this.errorMsg      = err.error?.error ?? 'Error al eliminar.';
        this.deleteLoading = false;
        this.cancelDelete();
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────
  logout(): void {
    localStorage.removeItem('token');
    sessionStorage.removeItem('token');
    this.router.navigate(['/login']);
  }

  goToDashboard(): void { this.router.navigate(['/dashboard']); }

  private emptyForm(): CategoryBody {
    return { name: '', color: '#2563EB', icon: '' };
  }

  labelStatus(s: string): string {
    return ({ PENDING: 'Pendiente', IN_PROGRESS: 'En Progreso', COMPLETED: 'Completada' } as any)[s] ?? s;
  }
}
