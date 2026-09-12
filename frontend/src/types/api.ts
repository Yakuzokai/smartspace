export interface ApiMetaLink {
  url: string | null
  label: string
  active: boolean
}

export interface ApiMeta {
  current_page: number
  from: number | null
  last_page: number
  links: ApiMetaLink[]
  path: string
  per_page: number
  to: number | null
  total: number
}

export interface ApiLinks {
  first: string | null
  last: string | null
  prev: string | null
  next: string | null
}

export interface PaginatedResponse<T> {
  data: T[]
  links?: ApiLinks
  meta?: ApiMeta
}

export interface ApiResponse<T> {
  data: T
  message?: string
}
