# Knowledge Base Search System - Performance Optimization Strategy

## Overview

This document outlines comprehensive performance optimization strategies for the knowledge base search system, covering all layers from frontend to backend, database, and infrastructure optimizations.

## Performance Goals

### Target Metrics
- **Search Response Time**: < 200ms for 95% of queries
- **Page Load Time**: < 2 seconds for initial load
- **Time to Interactive**: < 3 seconds
- **Throughput**: 1000+ concurrent users
- **Availability**: 99.9% uptime
- **Error Rate**: < 0.1%

### Performance Budget
```javascript
const performanceBudget = {
  // Network
  totalPageSize: '2MB',
  initialPageSize: '500KB',
  criticalResourceSize: '150KB',
  
  // Timing
  firstContentfulPaint: '1.5s',
  largestContentfulPaint: '2.5s',
  firstInputDelay: '100ms',
  cumulativeLayoutShift: '0.1',
  
  // Search Performance
  searchResponseTime: '200ms',
  indexingLatency: '5s',
  cacheHitRatio: '85%'
};
```

## Frontend Performance Optimization

### 1. Code Splitting and Lazy Loading

```javascript
// Dynamic imports for route-based code splitting
const SearchResults = lazy(() => import('./components/SearchResults'));
const ArticleView = lazy(() => import('./components/ArticleView'));
const AdminPanel = lazy(() => import('./components/AdminPanel'));

// Component-level code splitting
const AdvancedSearch = lazy(() => 
  import('./components/AdvancedSearch').then(module => ({
    default: module.AdvancedSearch
  }))
);

// Feature-based splitting
const Analytics = lazy(() => 
  import(/* webpackChunkName: "analytics" */ './features/Analytics')
);

// Route configuration with lazy loading
const routes = [
  {
    path: '/search',
    component: lazy(() => import('./pages/SearchPage')),
    preload: true // Preload on hover/focus
  },
  {
    path: '/article/:id',
    component: lazy(() => import('./pages/ArticlePage')),
    preload: false
  },
  {
    path: '/admin',
    component: lazy(() => import('./pages/AdminPage')),
    preload: false,
    requiresAuth: true
  }
];
```

### 2. Resource Optimization

```javascript
// Image optimization
class ImageOptimizer {
  static generateSrcSet(imagePath, sizes = [320, 640, 1024, 1920]) {
    return sizes.map(size => 
      `${imagePath}?w=${size}&q=80&f=webp ${size}w`
    ).join(', ');
  }
  
  static lazyLoadImages() {
    const imageObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = img.dataset.src;
          img.srcset = img.dataset.srcset;
          img.classList.remove('lazy');
          observer.unobserve(img);
        }
      });
    });
    
    document.querySelectorAll('img[data-src]').forEach(img => {
      imageObserver.observe(img);
    });
  }
}

// Font optimization
const fontPreload = `
  <link rel="preload" href="/fonts/inter-var.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="preload" href="/fonts/source-code-pro.woff2" as="font" type="font/woff2" crossorigin>
`;

// CSS optimization
const criticalCSS = `
  /* Critical above-the-fold styles */
  .header, .search-form, .hero-section {
    /* Inline critical styles */
  }
`;

// Non-critical CSS loading
function loadNonCriticalCSS() {
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = '/css/non-critical.css';
  link.media = 'print';
  link.onload = function() {
    this.media = 'all';
  };
  document.head.appendChild(link);
}
```

### 3. Caching Strategy

```javascript
// Service Worker for caching
class CacheStrategy {
  constructor() {
    this.CACHE_NAME = 'kb-search-v1';
    this.STATIC_CACHE = 'static-v1';
    this.API_CACHE = 'api-v1';
    this.IMAGE_CACHE = 'images-v1';
  }
  
  async install() {
    const cache = await caches.open(this.STATIC_CACHE);
    return cache.addAll([
      '/',
      '/css/critical.css',
      '/js/app.js',
      '/js/vendor.js',
      '/fonts/inter-var.woff2',
      '/manifest.json'
    ]);
  }
  
  async handleFetch(event) {
    const { request } = event;
    const url = new URL(request.url);
    
    // API requests - Network first, cache fallback
    if (url.pathname.startsWith('/api/')) {
      return this.networkFirst(request, this.API_CACHE);
    }
    
    // Images - Cache first, network fallback
    if (request.destination === 'image') {
      return this.cacheFirst(request, this.IMAGE_CACHE);
    }
    
    // Static assets - Cache first
    if (url.pathname.match(/\.(js|css|woff2)$/)) {
      return this.cacheFirst(request, this.STATIC_CACHE);
    }
    
    // HTML pages - Network first
    return this.networkFirst(request, this.CACHE_NAME);
  }
  
  async networkFirst(request, cacheName) {
    try {
      const response = await fetch(request);
      const cache = await caches.open(cacheName);
      cache.put(request, response.clone());
      return response;
    } catch (error) {
      const cachedResponse = await caches.match(request);
      return cachedResponse || new Response('Offline', { status: 503 });
    }
  }
  
  async cacheFirst(request, cacheName) {
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      return cachedResponse;
    }
    
    try {
      const response = await fetch(request);
      const cache = await caches.open(cacheName);
      cache.put(request, response.clone());
      return response;
    } catch (error) {
      return new Response('Resource not available', { status: 404 });
    }
  }
}
```

### 4. Virtual Scrolling for Large Result Sets

```javascript
// Virtual scrolling implementation
class VirtualScrollList {
  constructor(container, itemHeight, renderItem) {
    this.container = container;
    this.itemHeight = itemHeight;
    this.renderItem = renderItem;
    this.scrollTop = 0;
    this.containerHeight = container.clientHeight;
    this.visibleStart = 0;
    this.visibleEnd = 0;
    this.items = [];
    
    this.setupScrollListener();
  }
  
  setItems(items) {
    this.items = items;
    this.updateVisibleRange();
    this.render();
  }
  
  setupScrollListener() {
    this.container.addEventListener('scroll', () => {
      this.scrollTop = this.container.scrollTop;
      this.updateVisibleRange();
      this.render();
    });
  }
  
  updateVisibleRange() {
    const buffer = 5; // Render extra items for smooth scrolling
    this.visibleStart = Math.max(0, 
      Math.floor(this.scrollTop / this.itemHeight) - buffer
    );
    this.visibleEnd = Math.min(this.items.length - 1,
      Math.ceil((this.scrollTop + this.containerHeight) / this.itemHeight) + buffer
    );
  }
  
  render() {
    const visibleItems = this.items.slice(this.visibleStart, this.visibleEnd + 1);
    const offsetY = this.visibleStart * this.itemHeight;
    
    this.container.innerHTML = `
      <div style="height: ${this.items.length * this.itemHeight}px; position: relative;">
        <div style="transform: translateY(${offsetY}px);">
          ${visibleItems.map((item, index) => 
            this.renderItem(item, this.visibleStart + index)
          ).join('')}
        </div>
      </div>
    `;
  }
}

// Usage for search results
const searchResultsList = new VirtualScrollList(
  document.getElementById('search-results'),
  120, // Item height in pixels
  (result, index) => `
    <div class="result-item" data-index="${index}">
      <h3>${result.title}</h3>
      <p>${result.summary}</p>
    </div>
  `
);
```

## Backend Performance Optimization

### 1. API Response Optimization

```javascript
// Response compression and optimization
class ResponseOptimizer {
  constructor() {
    this.compressionThreshold = 1024; // 1KB
  }
  
  optimizeResponse(data, request) {
    // Remove unnecessary fields based on client needs
    const optimizedData = this.removeUnusedFields(data, request.query.fields);
    
    // Compress large responses
    if (JSON.stringify(optimizedData).length > this.compressionThreshold) {
      return this.compressResponse(optimizedData);
    }
    
    return optimizedData;
  }
  
  removeUnusedFields(data, requestedFields) {
    if (!requestedFields) return data;
    
    const fields = requestedFields.split(',');
    
    if (Array.isArray(data)) {
      return data.map(item => this.pickFields(item, fields));
    }
    
    return this.pickFields(data, fields);
  }
  
  pickFields(obj, fields) {
    const result = {};
    fields.forEach(field => {
      if (obj.hasOwnProperty(field)) {
        result[field] = obj[field];
      }
    });
    return result;
  }
  
  compressResponse(data) {
    // Implement response compression
    return {
      compressed: true,
      data: this.compress(JSON.stringify(data))
    };
  }
}

// Connection pooling
class DatabasePool {
  constructor(config) {
    this.pool = new Pool({
      host: config.host,
      port: config.port,
      database: config.database,
      user: config.user,
      password: config.password,
      max: 20, // Maximum pool size
      min: 5,  // Minimum pool size
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
      acquireTimeoutMillis: 60000,
      createTimeoutMillis: 30000,
      destroyTimeoutMillis: 5000,
      reapIntervalMillis: 1000,
      createRetryIntervalMillis: 200
    });
  }
  
  async query(text, params) {
    const start = Date.now();
    const client = await this.pool.connect();
    
    try {
      const result = await client.query(text, params);
      const duration = Date.now() - start;
      
      // Log slow queries
      if (duration > 1000) {
        console.warn(`Slow query detected: ${duration}ms`, { text, params });
      }
      
      return result;
    } finally {
      client.release();
    }
  }
}
```

### 2. Caching Layers

```javascript
// Multi-level caching strategy
class CacheManager {
  constructor() {
    this.l1Cache = new Map(); // In-memory cache
    this.l2Cache = new RedisCache(); // Redis cache
    this.l3Cache = new DatabaseCache(); // Database cache
    
    this.defaultTTL = 300; // 5 minutes
    this.maxL1Size = 1000; // Maximum L1 cache entries
  }
  
  async get(key, options = {}) {
    const { ttl = this.defaultTTL, skipL1 = false } = options;
    
    // L1 Cache (Memory)
    if (!skipL1 && this.l1Cache.has(key)) {
      const cached = this.l1Cache.get(key);
      if (cached.expires > Date.now()) {
        return cached.value;
      }
      this.l1Cache.delete(key);
    }
    
    // L2 Cache (Redis)
    const l2Value = await this.l2Cache.get(key);
    if (l2Value) {
      this.setL1Cache(key, l2Value, ttl);
      return l2Value;
    }
    
    // L3 Cache (Database)
    const l3Value = await this.l3Cache.get(key);
    if (l3Value) {
      await this.l2Cache.set(key, l3Value, ttl);
      this.setL1Cache(key, l3Value, ttl);
      return l3Value;
    }
    
    return null;
  }
  
  async set(key, value, ttl = this.defaultTTL) {
    // Set in all cache levels
    this.setL1Cache(key, value, ttl);
    await this.l2Cache.set(key, value, ttl);
    await this.l3Cache.set(key, value, ttl);
  }
  
  setL1Cache(key, value, ttl) {
    // Implement LRU eviction if cache is full
    if (this.l1Cache.size >= this.maxL1Size) {
      const firstKey = this.l1Cache.keys().next().value;
      this.l1Cache.delete(firstKey);
    }
    
    this.l1Cache.set(key, {
      value,
      expires: Date.now() + (ttl * 1000)
    });
  }
  
  async invalidate(pattern) {
    // Invalidate across all cache levels
    const keys = Array.from(this.l1Cache.keys()).filter(key => 
      key.match(new RegExp(pattern))
    );
    
    keys.forEach(key => this.l1Cache.delete(key));
    await this.l2Cache.invalidatePattern(pattern);
    await this.l3Cache.invalidatePattern(pattern);
  }
}

// Search result caching
class SearchCache {
  constructor(cacheManager) {
    this.cache = cacheManager;
    this.searchTTL = 600; // 10 minutes
    this.facetTTL = 1800; // 30 minutes
  }
  
  generateCacheKey(query, filters, sort, page, size) {
    const keyData = {
      query: query || '',
      filters: this.normalizeFilters(filters),
      sort: sort || 'relevance',
      page: page || 1,
      size: size || 20
    };
    
    return `search:${this.hashObject(keyData)}`;
  }
  
  async getCachedResults(cacheKey) {
    return await this.cache.get(cacheKey, { ttl: this.searchTTL });
  }
  
  async setCachedResults(cacheKey, results) {
    await this.cache.set(cacheKey, results, this.searchTTL);
  }
  
  async getCachedFacets(query, filters) {
    const facetKey = `facets:${this.hashObject({ query, filters })}`;
    return await this.cache.get(facetKey, { ttl: this.facetTTL });
  }
  
  async setCachedFacets(query, filters, facets) {
    const facetKey = `facets:${this.hashObject({ query, filters })}`;
    await this.cache.set(facetKey, facets, this.facetTTL);
  }
  
  normalizeFilters(filters) {
    if (!filters) return {};
    
    const normalized = {};
    Object.keys(filters).sort().forEach(key => {
      normalized[key] = Array.isArray(filters[key]) 
        ? filters[key].sort() 
        : filters[key];
    });
    
    return normalized;
  }
  
  hashObject(obj) {
    return crypto
      .createHash('md5')
      .update(JSON.stringify(obj))
      .digest('hex');
  }
}
```

## Database Performance Optimization

### 1. Query Optimization

```sql
-- Index optimization for search queries
CREATE INDEX CONCURRENTLY idx_articles_search_vector 
ON articles USING GIN(search_vector);

CREATE INDEX CONCURRENTLY idx_articles_category_status 
ON articles(category_id, status) 
WHERE status = 'published';

CREATE INDEX CONCURRENTLY idx_articles_published_at_desc 
ON articles(published_at DESC) 
WHERE status = 'published';

CREATE INDEX CONCURRENTLY idx_articles_popularity 
ON articles(view_count DESC, like_count DESC) 
WHERE status = 'published';

-- Partial indexes for common filters
CREATE INDEX CONCURRENTLY idx_articles_recent 
ON articles(created_at DESC) 
WHERE created_at > NOW() - INTERVAL '30 days' 
AND status = 'published';

-- Composite indexes for faceted search
CREATE INDEX CONCURRENTLY idx_articles_facets 
ON articles(category_id, author_id, status, published_at);

-- Optimized search query
EXPLAIN (ANALYZE, BUFFERS) 
SELECT 
  a.id,
  a.title,
  a.summary,
  a.slug,
  a.published_at,
  a.view_count,
  a.like_count,
  c.name as category_name,
  u.username as author_name,
  ts_rank(a.search_vector, plainto_tsquery('english', $1)) as rank
FROM articles a
JOIN categories c ON a.category_id = c.id
JOIN users u ON a.author_id = u.id
WHERE 
  a.status = 'published'
  AND a.search_vector @@ plainto_tsquery('english', $1)
  AND ($2::uuid IS NULL OR a.category_id = $2)
  AND ($3::uuid IS NULL OR a.author_id = $3)
ORDER BY rank DESC, a.published_at DESC
LIMIT $4 OFFSET $5;
```

### 2. Connection Optimization

```javascript
// Database connection optimization
class OptimizedDatabase {
  constructor(config) {
    this.readPool = new Pool({
      ...config,
      host: config.readHost,
      max: 15,
      statement_timeout: 30000,
      query_timeout: 30000
    });
    
    this.writePool = new Pool({
      ...config,
      host: config.writeHost,
      max: 5,
      statement_timeout: 60000,
      query_timeout: 60000
    });
    
    this.setupMonitoring();
  }
  
  async read(query, params) {
    return this.executeQuery(this.readPool, query, params);
  }
  
  async write(query, params) {
    return this.executeQuery(this.writePool, query, params);
  }
  
  async executeQuery(pool, query, params) {
    const start = Date.now();
    const client = await pool.connect();
    
    try {
      const result = await client.query(query, params);
      const duration = Date.now() - start;
      
      this.recordMetrics('query_duration', duration);
      
      if (duration > 5000) {
        console.warn('Slow query detected', {
          query: query.substring(0, 100),
          duration,
          params: params?.length
        });
      }
      
      return result;
    } catch (error) {
      this.recordMetrics('query_error', 1);
      throw error;
    } finally {
      client.release();
    }
  }
  
  setupMonitoring() {
    setInterval(() => {
      console.log('Pool stats:', {
        read: {
          total: this.readPool.totalCount,
          idle: this.readPool.idleCount,
          waiting: this.readPool.waitingCount
        },
        write: {
          total: this.writePool.totalCount,
          idle: this.writePool.idleCount,
          waiting: this.writePool.waitingCount
        }
      });
    }, 60000);
  }
  
  recordMetrics(metric, value) {
    // Send metrics to monitoring system
    if (global.metrics) {
      global.metrics.record(metric, value);
    }
  }
}
```

## Elasticsearch Performance Optimization

### 1. Index Optimization

```javascript
// Elasticsearch optimization settings
const optimizedIndexSettings = {
  settings: {
    number_of_shards: 2,
    number_of_replicas: 1,
    refresh_interval: '30s', // Reduce refresh frequency
    
    // Memory optimization
    'index.codec': 'best_compression',
    'index.merge.policy.max_merged_segment': '2gb',
    'index.merge.policy.segments_per_tier': 4,
    
    // Search optimization
    'index.queries.cache.enabled': true,
    'index.requests.cache.enable': true,
    
    // Analysis optimization
    analysis: {
      analyzer: {
        optimized_search: {
          type: 'custom',
          tokenizer: 'standard',
          filter: [
            'lowercase',
            'stop',
            'stemmer',
            'synonym_filter'
          ]
        }
      },
      filter: {
        synonym_filter: {
          type: 'synonym',
          synonyms: [
            'login,signin,authentication',
            'password,pwd,passphrase',
            'error,issue,problem'
          ]
        }
      }
    }
  },
  
  mappings: {
    dynamic: 'strict',
    properties: {
      title: {
        type: 'text',
        analyzer: 'optimized_search',
        fields: {
          keyword: { type: 'keyword' },
          suggest: {
            type: 'completion',
            analyzer: 'simple',
            preserve_separators: true,
            preserve_position_increments: true,
            max_input_length: 50
          }
        }
      },
      content: {
        type: 'text',
        analyzer: 'optimized_search',
        index_options: 'offsets', // Enable highlighting
        term_vector: 'with_positions_offsets'
      },
      category: {
        type: 'keyword',
        eager_global_ordinals: true // Optimize aggregations
      },
      tags: {
        type: 'keyword',
        eager_global_ordinals: true
      },
      published_at: {
        type: 'date',
        format: 'strict_date_optional_time||epoch_millis'
      },
      popularity_score: {
        type: 'float',
        doc_values: true // Enable sorting
      }
    }
  }
};
```

### 2. Query Optimization

```javascript
// Optimized search queries
class OptimizedSearchQueries {
  buildSearchQuery(params) {
    const {
      query,
      filters = {},
      sort = 'relevance',
      from = 0,
      size = 20,
      highlight = true
    } = params;
    
    const searchQuery = {
      index: 'kb-articles',
      body: {
        query: this.buildMainQuery(query, filters),
        sort: this.buildSort(sort),
        from,
        size,
        _source: {
          excludes: ['content'] // Exclude large fields from results
        },
        highlight: highlight ? this.buildHighlight() : undefined,
        aggs: this.buildAggregations(filters),
        track_total_hits: size === 0 ? true : 10000 // Limit total hits calculation
      }
    };
    
    return searchQuery;
  }
  
  buildMainQuery(query, filters) {
    const must = [];
    const filter = [];
    
    // Main search query
    if (query) {
      must.push({
        multi_match: {
          query,
          type: 'best_fields',
          fields: [
            'title^3',
            'summary^2',
            'content'
          ],
          fuzziness: 'AUTO',
          prefix_length: 2,
          max_expansions: 50
        }
      });
    } else {
      must.push({ match_all: {} });
    }
    
    // Filters
    if (filters.category) {
      filter.push({ terms: { category: Array.isArray(filters.category) ? filters.category : [filters.category] } });
    }
    
    if (filters.tags) {
      filter.push({ terms: { tags: Array.isArray(filters.tags) ? filters.tags : [filters.tags] } });
    }
    
    if (filters.dateRange) {
      filter.push({
        range: {
          published_at: {
            gte: filters.dateRange.from,
            lte: filters.dateRange.to
          }
        }
      });
    }
    
    // Always filter by published status
    filter.push({ term: { status: 'published' } });
    
    return {
      bool: {
        must,
        filter,
        should: [
          // Boost popular content
          {
            function_score: {
              field_value_factor: {
                field: 'popularity_score',
                factor: 1.2,
                modifier: 'log1p',
                missing: 0
              }
            }
          },
          // Boost recent content
          {
            function_score: {
              gauss: {
                published_at: {
                  origin: 'now',
                  scale: '30d',
                  decay: 0.5
                }
              }
            }
          }
        ],
        minimum_should_match: 0
      }
    };
  }
  
  buildSort(sortType) {
    const sortOptions = {
      relevance: [
        '_score',
        { published_at: { order: 'desc' } }
      ],
      date: [
        { published_at: { order: 'desc' } },
        '_score'
      ],
      popularity: [
        { popularity_score: { order: 'desc' } },
        '_score'
      ],
      title: [
        { 'title.keyword': { order: 'asc' } }
      ]
    };
    
    return sortOptions[sortType] || sortOptions.relevance;
  }
  
  buildHighlight() {
    return {
      pre_tags: ['<mark>'],
      post_tags: ['</mark>'],
      fields: {
        title: {
          fragment_size: 150,
          number_of_fragments: 1
        },
        summary: {
          fragment_size: 200,
          number_of_fragments: 2
        },
        content: {
          fragment_size: 150,
          number_of_fragments: 3
        }
      }
    };
  }
  
  buildAggregations(currentFilters) {
    return {
      categories: {
        filter: this.buildFilterExcluding(currentFilters, 'category'),
        aggs: {
          categories: {
            terms: {
              field: 'category',
              size: 20,
              order: { _count: 'desc' }
            }
          }
        }
      },
      tags: {
        filter: this.buildFilterExcluding(currentFilters, 'tags'),
        aggs: {
          tags: {
            terms: {
              field: 'tags',
              size: 50,
              order: { _count: 'desc' }
            }
          }
        }
      }
    };
  }
  
  buildFilterExcluding(filters, excludeField) {
    const filterClauses = [];
    
    Object.keys(filters).forEach(field => {
      if (field !== excludeField) {
        if (field === 'category') {
          filterClauses.push({ terms: { category: Array.isArray(filters[field]) ? filters[field] : [filters[field]] } });
        } else if (field === 'tags') {
          filterClauses.push({ terms: { tags: Array.isArray(filters[field]) ? filters[field] : [filters[field]] } });
        }
      }
    });
    
    filterClauses.push({ term: { status: 'published' } });
    
    return filterClauses.length > 0 ? { bool: { must: filterClauses } } : { match_all: {} };
  }
}
```

## Performance Monitoring

### 1. Real-time Performance Metrics

```javascript
// Performance monitoring system
class PerformanceMonitor {
  constructor() {
    this.metrics = new Map();
    this.thresholds = {
      searchResponseTime: 200,
      dbQueryTime: 100,
      cacheHitRatio: 0.8,
      errorRate: 0.01
    };
    
    this.setupMetricsCollection();
  }
  
  recordMetric(name, value, tags = {}) {
    const timestamp = Date.now();
    const metricKey = `${name}:${JSON.stringify(tags)}`;
    
    if (!this.metrics.has(metricKey)) {
      this.metrics.set(metricKey, []);
    }
    
    const values = this.metrics.get(metricKey);
    values.push({ value, timestamp });
    
    // Keep only last 1000 values
    if (values.length > 1000) {
      values.shift();
    }
    
    // Check thresholds
    this.checkThresholds(name, value, tags);
  }
  
  checkThresholds(name, value, tags) {
    const threshold = this.thresholds[name];
    if (!threshold) return;
    
    if (value > threshold) {
      this.triggerAlert({
        metric: name,
        value,
        threshold,
        tags,
        timestamp: Date.now()
      });
    }
  }
  
  getMetricSummary(name, timeWindow = 300000) { // 5 minutes
    const now = Date.now();
    const cutoff = now - timeWindow;
    
    const allValues = [];
    
    for (const [key, values] of this.metrics.entries()) {
      if (key.startsWith(name)) {
        const recentValues = values
          .filter(v => v.timestamp > cutoff)
          .map(v => v.value);
        allValues.push(...recentValues);
      }
    }
    
    if (allValues.length === 0) return null;
    
    allValues.sort((a, b) => a - b);
    
    return {
      count: allValues.length,
      min: allValues[0],
      max: allValues[allValues.length - 1],
      avg: allValues.reduce((sum, v) => sum + v, 0) / allValues.length,
      p50: allValues[Math.floor(allValues.length * 0.5)],
      p95: allValues[Math.floor(allValues.length * 0.95)],
      p99: allValues[Math.floor(allValues.length * 0.99)]
    };
  }
setupMetricsCollection() {
    // Collect system metrics every 30 seconds
    setInterval(() => {
      this.collectSystemMetrics();
    }, 30000);
    
    // Collect application metrics every 10 seconds
    setInterval(() => {
      this.collectApplicationMetrics();
    }, 10000);
  }
  
  collectSystemMetrics() {
    const memUsage = process.memoryUsage();
    this.recordMetric('memory_usage', memUsage.heapUsed / 1024 / 1024); // MB
    this.recordMetric('memory_total', memUsage.heapTotal / 1024 / 1024); // MB
    
    const cpuUsage = process.cpuUsage();
    this.recordMetric('cpu_usage', (cpuUsage.user + cpuUsage.system) / 1000000); // seconds
  }
  
  collectApplicationMetrics() {
    // Cache hit ratio
    const cacheStats = global.cacheManager?.getStats();
    if (cacheStats) {
      const hitRatio = cacheStats.hits / (cacheStats.hits + cacheStats.misses);
      this.recordMetric('cache_hit_ratio', hitRatio);
    }
    
    // Active connections
    const dbStats = global.database?.getStats();
    if (dbStats) {
      this.recordMetric('db_connections_active', dbStats.activeConnections);
      this.recordMetric('db_connections_idle', dbStats.idleConnections);
    }
  }
  
  triggerAlert(alert) {
    console.warn('Performance threshold exceeded:', alert);
    
    // Send to alerting system
    if (global.alertManager) {
      global.alertManager.sendAlert({
        type: 'performance',
        severity: 'warning',
        ...alert
      });
    }
  }
}
```

### 2. Performance Testing Framework

```javascript
// Automated performance testing
class PerformanceTestSuite {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
    this.results = [];
  }
  
  async runAllTests() {
    console.log('Starting performance test suite...');
    
    const tests = [
      this.testSearchPerformance,
      this.testPageLoadPerformance,
      this.testConcurrentUsers,
      this.testDatabasePerformance,
      this.testCachePerformance
    ];
    
    for (const test of tests) {
      try {
        const result = await test.call(this);
        this.results.push(result);
        console.log(`✓ ${result.name}: ${result.status}`);
      } catch (error) {
        console.error(`✗ ${test.name}: ${error.message}`);
        this.results.push({
          name: test.name,
          status: 'failed',
          error: error.message
        });
      }
    }
    
    return this.generateReport();
  }
  
  async testSearchPerformance() {
    const testQueries = [
      'authentication',
      'user management',
      'api documentation',
      'deployment guide',
      'troubleshooting'
    ];
    
    const results = [];
    
    for (const query of testQueries) {
      const start = Date.now();
      const response = await fetch(`${this.baseUrl}/api/v1/search?q=${encodeURIComponent(query)}`);
      const duration = Date.now() - start;
      
      if (!response.ok) {
        throw new Error(`Search failed for query: ${query}`);
      }
      
      const data = await response.json();
      results.push({
        query,
        duration,
        resultCount: data.total,
        responseSize: JSON.stringify(data).length
      });
    }
    
    const avgDuration = results.reduce((sum, r) => sum + r.duration, 0) / results.length;
    const maxDuration = Math.max(...results.map(r => r.duration));
    
    return {
      name: 'Search Performance',
      status: maxDuration < 200 ? 'passed' : 'failed',
      metrics: {
        averageDuration: avgDuration,
        maxDuration: maxDuration,
        testCount: results.length
      },
      details: results
    };
  }
  
  async testPageLoadPerformance() {
    const pages = [
      '/',
      '/search?q=test',
      '/article/sample-article'
    ];
    
    const results = [];
    
    for (const page of pages) {
      const start = Date.now();
      const response = await fetch(`${this.baseUrl}${page}`);
      const duration = Date.now() - start;
      
      if (!response.ok) {
        throw new Error(`Page load failed: ${page}`);
      }
      
      const contentLength = response.headers.get('content-length') || 0;
      results.push({
        page,
        duration,
        contentLength: parseInt(contentLength)
      });
    }
    
    const avgDuration = results.reduce((sum, r) => sum + r.duration, 0) / results.length;
    const maxDuration = Math.max(...results.map(r => r.duration));
    
    return {
      name: 'Page Load Performance',
      status: maxDuration < 2000 ? 'passed' : 'failed',
      metrics: {
        averageDuration: avgDuration,
        maxDuration: maxDuration,
        testCount: results.length
      },
      details: results
    };
  }
  
  async testConcurrentUsers() {
    const concurrentRequests = 50;
    const testDuration = 30000; // 30 seconds
    
    const startTime = Date.now();
    const promises = [];
    let requestCount = 0;
    let errorCount = 0;
    
    // Generate concurrent requests
    for (let i = 0; i < concurrentRequests; i++) {
      const promise = this.simulateUserSession(testDuration)
        .then(() => requestCount++)
        .catch(() => errorCount++);
      promises.push(promise);
    }
    
    await Promise.all(promises);
    
    const actualDuration = Date.now() - startTime;
    const requestsPerSecond = (requestCount * 1000) / actualDuration;
    const errorRate = errorCount / (requestCount + errorCount);
    
    return {
      name: 'Concurrent Users',
      status: errorRate < 0.05 ? 'passed' : 'failed',
      metrics: {
        concurrentUsers: concurrentRequests,
        requestsPerSecond: requestsPerSecond,
        errorRate: errorRate,
        totalRequests: requestCount + errorCount
      }
    };
  }
  
  async simulateUserSession(duration) {
    const endTime = Date.now() + duration;
    const actions = [
      () => fetch(`${this.baseUrl}/api/v1/search?q=test`),
      () => fetch(`${this.baseUrl}/api/v1/search?q=authentication`),
      () => fetch(`${this.baseUrl}/api/v1/articles/sample-article`),
      () => fetch(`${this.baseUrl}/api/v1/search/suggest?q=user`)
    ];
    
    while (Date.now() < endTime) {
      const action = actions[Math.floor(Math.random() * actions.length)];
      await action();
      await new Promise(resolve => setTimeout(resolve, Math.random() * 2000 + 500));
    }
  }
  
  generateReport() {
    const passedTests = this.results.filter(r => r.status === 'passed').length;
    const totalTests = this.results.length;
    
    return {
      summary: {
        totalTests,
        passedTests,
        failedTests: totalTests - passedTests,
        successRate: (passedTests / totalTests) * 100
      },
      results: this.results,
      timestamp: new Date().toISOString()
    };
  }
}
```

## Infrastructure Performance Optimization

### 1. CDN Configuration

```javascript
// CDN optimization configuration
const cdnConfig = {
  // CloudFront configuration
  cloudfront: {
    origins: [
      {
        domainName: 'kb.company.com',
        originPath: '/static',
        customOriginConfig: {
          httpPort: 80,
          httpsPort: 443,
          originProtocolPolicy: 'https-only',
          originSslProtocols: ['TLSv1.2']
        }
      }
    ],
    
    defaultCacheBehavior: {
      targetOriginId: 'kb-origin',
      viewerProtocolPolicy: 'redirect-to-https',
      compress: true,
      cachePolicyId: 'optimized-caching',
      
      // Cache headers
      forwardedValues: {
        queryString: false,
        cookies: { forward: 'none' },
        headers: ['Accept-Encoding', 'CloudFront-Viewer-Country']
      },
      
      // TTL settings
      minTTL: 0,
      defaultTTL: 86400, // 24 hours
      maxTTL: 31536000   // 1 year
    },
    
    cacheBehaviors: [
      {
        pathPattern: '/api/*',
        targetOriginId: 'kb-api-origin',
        cachePolicyId: 'api-caching',
        minTTL: 0,
        defaultTTL: 300, // 5 minutes
        maxTTL: 3600     // 1 hour
      },
      {
        pathPattern: '/static/*',
        targetOriginId: 'kb-static-origin',
        cachePolicyId: 'static-caching',
        minTTL: 86400,   // 24 hours
        defaultTTL: 604800, // 7 days
        maxTTL: 31536000    // 1 year
      }
    ]
  },
  
  // Cache invalidation strategy
  invalidation: {
    patterns: [
      '/api/v1/search/*',
      '/static/js/*',
      '/static/css/*'
    ],
    triggers: [
      'deployment',
      'content_update',
      'configuration_change'
    ]
  }
};
```

### 2. Load Balancer Optimization

```yaml
# Load balancer configuration
apiVersion: v1
kind: Service
metadata:
  name: kb-search-lb
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
    service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "60"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval: "10"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-timeout: "5"
    service.beta.kubernetes.io/aws-load-balancer-healthy-threshold: "2"
    service.beta.kubernetes.io/aws-load-balancer-unhealthy-threshold: "3"
spec:
  type: LoadBalancer
  selector:
    app: kb-search-api
  ports:
  - port: 80
    targetPort: 3000
    protocol: TCP

---
# Ingress with optimized settings
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kb-search-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    
    # Performance optimizations
    nginx.ingress.kubernetes.io/proxy-buffering: "on"
    nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"
    nginx.ingress.kubernetes.io/proxy-buffers-number: "8"
    nginx.ingress.kubernetes.io/client-body-buffer-size: "1m"
    nginx.ingress.kubernetes.io/client-max-body-size: "10m"
    
    # Compression
    nginx.ingress.kubernetes.io/enable-brotli: "true"
    nginx.ingress.kubernetes.io/brotli-level: "6"
    nginx.ingress.kubernetes.io/brotli-types: "text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript"
    
    # Caching
    nginx.ingress.kubernetes.io/proxy-cache-valid: "200 302 10m"
    nginx.ingress.kubernetes.io/proxy-cache-valid: "404 1m"
    
    # Rate limiting
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  rules:
  - host: kb.company.com
    http:
      paths:
      - path: /api/(.*)
        pathType: Prefix
        backend:
          service:
            name: kb-search-api-service
            port:
              number: 80
      - path: /(.*)
        pathType: Prefix
        backend:
          service:
            name: kb-frontend-service
            port:
              number: 80
```

## Performance Optimization Checklist

### Frontend Optimization
- [ ] Implement code splitting and lazy loading
- [ ] Optimize images with WebP format and responsive sizes
- [ ] Use service worker for caching
- [ ] Implement virtual scrolling for large lists
- [ ] Minimize and compress CSS/JavaScript
- [ ] Use CDN for static assets
- [ ] Implement critical CSS inlining
- [ ] Optimize web fonts loading

### Backend Optimization
- [ ] Implement multi-level caching
- [ ] Optimize database queries and indexes
- [ ] Use connection pooling
- [ ] Implement response compression
- [ ] Add request/response caching headers
- [ ] Optimize API payload sizes
- [ ] Implement rate limiting
- [ ] Use async processing for heavy operations

### Database Optimization
- [ ] Create appropriate indexes
- [ ] Implement read replicas
- [ ] Optimize query execution plans
- [ ] Use connection pooling
- [ ] Implement query result caching
- [ ] Monitor slow queries
- [ ] Optimize table schemas
- [ ] Implement database partitioning if needed

### Search Engine Optimization
- [ ] Optimize Elasticsearch cluster configuration
- [ ] Implement proper index settings
- [ ] Use appropriate analyzers and mappings
- [ ] Optimize search queries
- [ ] Implement search result caching
- [ ] Monitor cluster health
- [ ] Optimize shard allocation
- [ ] Use index templates

### Infrastructure Optimization
- [ ] Configure CDN properly
- [ ] Optimize load balancer settings
- [ ] Implement auto-scaling
- [ ] Use appropriate instance types
- [ ] Configure monitoring and alerting
- [ ] Implement proper logging
- [ ] Optimize network configuration
- [ ] Use container resource limits

## Performance Testing Schedule

### Continuous Testing
- **Unit Performance Tests**: Run with every commit
- **Integration Performance Tests**: Run with every deployment
- **Load Testing**: Weekly automated tests
- **Stress Testing**: Monthly comprehensive tests
- **Chaos Engineering**: Bi-weekly resilience tests

### Performance Benchmarks
```javascript
const performanceBenchmarks = {
  search: {
    responseTime: {
      target: 150,
      warning: 200,
      critical: 500
    },
    throughput: {
      target: 1000, // requests per second
      warning: 800,
      critical: 500
    }
  },
  
  database: {
    queryTime: {
      target: 50,
      warning: 100,
      critical: 500
    },
    connectionPool: {
      target: 80, // % utilization
      warning: 90,
      critical: 95
    }
  },
  
  cache: {
    hitRatio: {
      target: 90, // %
      warning: 80,
      critical: 70
    },
    responseTime: {
      target: 5,
      warning: 10,
      critical: 50
    }
  },
  
  infrastructure: {
    cpuUtilization: {
      target: 60, // %
      warning: 80,
      critical: 90
    },
    memoryUtilization: {
      target: 70, // %
      warning: 85,
      critical: 95
    }
  }
};
```

This comprehensive performance optimization strategy ensures the knowledge base search system delivers excellent user experience while maintaining scalability and reliability under various load conditions.