import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Category {
  _id:        string;
  name:       string;
  color:      string;
  icon?:      string;
  userId?:    string;
  createdAt?: string;
  updatedAt?: string;
}

export interface CategoryListResponse   { categories: Category[]; }
export interface CategoryDetailResponse { category: Category; tasks: any[]; }
export interface CategorySingleResponse { category: Category; }
export interface CategoryDeleteResponse { message: string; }

export interface CategoryBody {
  name:    string;
  color:   string;
  icon?:   string;
  userId?: string;
}

@Injectable({ providedIn: 'root' })
export class CategoryService {

  private apiUrl = 'http://localhost:3000/api/categories';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token = localStorage.getItem('token') ?? sessionStorage.getItem('token') ?? '';
    return new HttpHeaders({ Authorization: `Bearer ${token}` });
  }

  // GET todas las categorías del usuario  →  /api/categories/:userId
  getCategories(userId: string): Observable<CategoryListResponse> {
    return this.http.get<CategoryListResponse>(
      `${this.apiUrl}/${userId}`,
      { headers: this.headers() }
    );
  }

  // GET categoría + sus tareas  →  /api/categories/:id
  getCategoryById(id: string): Observable<CategoryDetailResponse> {
    return this.http.get<CategoryDetailResponse>(
      `${this.apiUrl}/${id}`,
      { headers: this.headers() }
    );
  }

  // POST crear  →  /api/categories
  createCategory(body: CategoryBody): Observable<CategorySingleResponse> {
    return this.http.post<CategorySingleResponse>(
      this.apiUrl, body,
      { headers: this.headers() }
    );
  }

  // PUT editar  →  /api/categories/:id
  updateCategory(id: string, body: Partial<CategoryBody>): Observable<CategorySingleResponse> {
    return this.http.put<CategorySingleResponse>(
      `${this.apiUrl}/${id}`, body,
      { headers: this.headers() }
    );
  }

  // DELETE  →  /api/categories/:id
  deleteCategory(id: string): Observable<CategoryDeleteResponse> {
    return this.http.delete<CategoryDeleteResponse>(
      `${this.apiUrl}/${id}`,
      { headers: this.headers() }
    );
  }
}
