import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Task {
  _id:         string;
  title:       string;
  description: string;
  status:      'PENDING' | 'IN_PROGRESS' | 'COMPLETED';
  priority:    'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';
  dueDate?:    string;
  categoryId?: string;
  userId?:     string;
  createdAt?:  string;
  updatedAt?:  string;
}

export interface TaskListResponse  { tasks: Task[]; }
export interface TaskSingleResponse { task: Task; }
export interface TaskDeleteResponse { message: string; }

export interface CreateTaskBody {
  title:        string;
  description?: string;
  status?:      Task['status'];
  priority?:    Task['priority'];
  dueDate?:     string;
  categoryId?:  string;
}

export interface UpdateTaskBody {
  title?:       string;
  description?: string;
  status?:      Task['status'];
  priority?:    Task['priority'];
  dueDate?:     string;
  categoryId?:  string;
}

@Injectable({ providedIn: 'root' })
export class TaskService {

  private apiUrl = 'http://localhost:3000/api/tasks';

  constructor(private http: HttpClient) {}

  // ── Headers con Bearer token ──────────────────────────────────────
  private headers(): HttpHeaders {
    const token = localStorage.getItem('token') ?? sessionStorage.getItem('token') ?? '';
    return new HttpHeaders({ Authorization: `Bearer ${token}` });
  }

  // ── GET todas las tareas del usuario ──────────────────────────────
  getTasks(userId: string): Observable<TaskListResponse> {
    return this.http.get<TaskListResponse>(
      `${this.apiUrl}/${userId}`,
      { headers: this.headers() }
    );
  }

  // ── POST crear tarea ──────────────────────────────────────────────
  createTask(body: CreateTaskBody): Observable<TaskSingleResponse> {
    return this.http.post<TaskSingleResponse>(
      this.apiUrl,
      body,
      { headers: this.headers() }
    );
  }

  // ── PUT actualizar tarea ──────────────────────────────────────────
  updateTask(id: string, body: UpdateTaskBody): Observable<TaskSingleResponse> {
    return this.http.put<TaskSingleResponse>(
      `${this.apiUrl}/${id}`,
      body,
      { headers: this.headers() }
    );
  }

  // ── DELETE eliminar tarea ─────────────────────────────────────────
  deleteTask(id: string): Observable<TaskDeleteResponse> {
    return this.http.delete<TaskDeleteResponse>(
      `${this.apiUrl}/${id}`,
      { headers: this.headers() }
    );
  }
}
