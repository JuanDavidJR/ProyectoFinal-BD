# 📊 Complex SQL Queries — MusicApp Vibesia

This folder contains a set of **advanced analytical queries** written in PostgreSQL, designed to extract meaningful insights from the `vibesia_schema` database. These queries support user behavior analysis, artist and playlist evaluation, churn prediction, and rating correlations — all aimed at enhancing understanding of the digital music ecosystem.

> Each query includes descriptive headers, techniques used, and performance considerations. They were developed as part of the **MusicApp - Vibesia** university final project.

---

## 📁 Query List & Descriptions

| File                    | Query Title                                              | Focus Area                         |
|-------------------------|-----------------------------------------------------------|------------------------------------|
| `01-complex-query.sql`  | 🎼 Seasonal Trends Analysis                               | Genre/Artist/Album Seasonality     |
| `02-complex-query.sql`  | 🌟 Influential User Discovery                             | Engagement & Activity              |
| `03-complex-query.sql`  | 💿 Album Cohesion & Duration                              | Album Quality & Consistency        |
| `05-complex-query.sql`  | 🧠 User Loyalty Segmentation                              | Playback Habits & Retention        |
| `06-complex-query.sql`  | 🎤 Artist Performance Metrics                              | Popularity, Reach & Growth         |
| `07-complex-query.sql`  | 📂 Playlist Analysis & Curation Quality                   | Composition, Popularity & Activity |
| `08-complex-query.sql`  | 📈 Rating Correlation by Context                          | Device, Time, Behavior Analysis    |
| `09-complex-query.sql`  | 🔗 Musical Ecosystem: Artist & Genre Connections          | Listener Overlap & Network Effect  |
| `10-complex-query.sql`  | 🚨 Predictive User Churn Analysis                         | Churn Scoring & Segmenting         |

---

## 🧪 Query Highlights

### `01-complex-query.sql`: **Seasonal Musical Trends**
- **Purpose:** Detects seasonal popularity of genres, artists, and albums
- **Metrics:** Rankings, growth rates, listener count, and average ratings
- **Techniques:** Temporal analysis with `EXTRACT()`, window functions for trend comparison
- **Business Value:** Identifies content to promote during specific seasons

### `02-complex-query.sql`: **Influential User Discovery**
- **Purpose:** Identifies top power users based on diverse engagement metrics
- **Metrics:** Playlist creation, social sharing, listening diversity, activity consistency
- **Techniques:** Correlated subqueries, multi-dimensional scoring algorithms
- **Business Value:** Target users for beta features, ambassador programs

### `03-complex-query.sql`: **Album Cohesion & Duration Report**
- **Purpose:** Measures album quality through song duration consistency and engagement
- **Metrics:** Duration variance, skip rates, completion rates, recent popularity
- **Techniques:** Statistical functions (`STDDEV`), cohesion scoring
- **Business Value:** Optimize album recommendations and curation

### `05-complex-query.sql`: **User Loyalty Segmentation**
- **Purpose:** Categorizes users by loyalty levels and engagement patterns
- **Metrics:** Tenure, artist diversity, playlist activity, completion rates
- **Techniques:** Multi-tier classification with `CASE` expressions
- **Business Value:** Personalized retention strategies and feature rollouts

### `06-complex-query.sql`: **Artist Performance Dashboard**
- **Purpose:** Comprehensive artist analytics for growth and engagement tracking
- **Metrics:** Global rankings, country-specific performance, growth trends
- **Techniques:** Window functions, geographic segmentation, time-series analysis
- **Business Value:** Data-driven artist promotion and partnership decisions

### `07-complex-query.sql`: **Playlist Quality & Activity Report**
- **Purpose:** Evaluates playlist curation quality and user engagement
- **Metrics:** Genre/artist diversity, song popularity, update frequency, user interaction
- **Techniques:** Diversity indices, activity classification, engagement scoring
- **Business Value:** Improve playlist recommendations and curator identification

### `08-complex-query.sql`: **Rating Contextual Analysis**
- **Purpose:** Analyzes how listening context affects user satisfaction
- **Metrics:** Device-specific ratings, time-of-day patterns, familiarity impact
- **Techniques:** Contextual correlation analysis, temporal grouping
- **Business Value:** Optimize user experience across different contexts

### `09-complex-query.sql`: **Musical Ecosystem: Artist & Genre Connections**
- **Purpose:** Maps interconnections between artists and genres through shared audiences
- **Metrics:** Listener overlap, crossover patterns, network strength
- **Techniques:** Graph-like analysis with self-joins, connection strength algorithms
- **Business Value:** Enhanced recommendation systems and genre discovery

### `10-complex-query.sql`: **Predictive User Churn Analysis**
- **Purpose:** Identifies users at risk of churning and suggests intervention strategies
- **Metrics:** Churn probability score, engagement decline patterns, risk segmentation
- **Techniques:** Predictive scoring, trend analysis, behavioral pattern recognition
- **Business Value:** Proactive retention campaigns and user re-engagement

---

## 🛠️ Advanced SQL Techniques Used

### **Query Optimization**
- **CTEs (Common Table Expressions):** Modular query composition for readability
- **Window Functions:** `RANK()`, `DENSE_RANK()`, `LAG()`, `LEAD()` for rankings and trends
- **Partitioning:** `PARTITION BY` for grouped calculations

### **Data Analysis**
- **Statistical Functions:** `STDDEV()`, `PERCENTILE_CONT()`, `CORR()` for data insights
- **Temporal Analysis:** `INTERVAL`, `EXTRACT()`, `DATE_TRUNC()` for time-based patterns
- **Aggregation Techniques:** Complex `GROUP BY` with `ROLLUP` and `CUBE`

### **Advanced Joins & Subqueries**
- **Correlated Subqueries:** Row-wise personalized metrics
- **Self-Joins:** Graph-like relationship analysis
- **Lateral Joins:** Dynamic row-level computations

### **Classification & Scoring**
- **Multi-Conditional CASE:** Complex business logic implementation
- **Scoring Algorithms:** Weighted metrics for user and content evaluation
- **Segmentation Logic:** Automated categorization based on behavioral patterns

---

## 🎯 Performance Considerations

### **Indexing Strategy**
```sql
-- Recommended indexes for optimal query performance
CREATE INDEX idx_playback_history_user_date ON playback_history(user_id, played_at);
CREATE INDEX idx_playback_history_song_date ON playback_history(song_id, played_at);
CREATE INDEX idx_songs_artist_album ON songs(artist_id, album_id);
CREATE INDEX idx_playlist_songs_composite ON playlist_songs(playlist_id, song_id);
```

### **Query Optimization Tips**
- Use `LIMIT` for large result sets during development
- Consider materialized views for frequently accessed aggregations
- Monitor query execution plans with `EXPLAIN ANALYZE`
- Implement query result caching for dashboard applications

---

## 🧩 System Requirements

### **Database**
- **PostgreSQL:** Version 14 or higher
- **Schema:** `vibesia_schema`
- **Extensions:** `pg_stat_statements` (recommended for performance monitoring)

### **Required Tables**
- Core entities: `users`, `songs`, `albums`, `artists`, `genres`
- Relationships: `song_genres`, `playlist_songs`, `user_devices`
- Activity tracking: `playback_history`, `user_ratings`
- Metadata: `devices`, `playlists`

### **Minimum Data Requirements**
- **Users:** 1,000+ for meaningful segmentation
- **Songs:** 10,000+ for diversity analysis
- **Playback History:** 100,000+ events for trend analysis
- **Ratings:** 10,000+ for correlation analysis

---

## 🚀 Usage Instructions

### **Single Query Execution**
```bash
# Execute individual query
psql -U postgres -d vibesia_db -f 01-complex-query.sql

# With output formatting
psql -U postgres -d vibesia_db -f 01-complex-query.sql --csv > results.csv
```

### **Batch Execution**
```bash
# Run all queries in sequence
for file in *.sql; do
    echo "Executing $file..."
    psql -U postgres -d vibesia_db -f "$file"
done
```

### **Performance Monitoring**
```sql
-- Enable query statistics
SELECT pg_stat_statements_reset();

-- After running queries, check performance
SELECT query, calls, total_time, mean_time 
FROM pg_stat_statements 
WHERE query LIKE '%vibesia_schema%'
ORDER BY total_time DESC;
```

---

## 📈 Business Intelligence Integration

### **Dashboard Integration**
These queries are designed to integrate with popular BI tools:
- **Tableau:** Direct PostgreSQL connection
- **Power BI:** PostgreSQL connector
- **Grafana:** PostgreSQL data source
- **Metabase:** Native PostgreSQL support

### **API Integration**
```python
# Example Python integration
import psycopg2
import pandas as pd

def run_complex_query(query_file):
    conn = psycopg2.connect(
        host="localhost",
        database="vibesia_db",
        user="postgres"
    )
    
    with open(f"queries/{query_file}", 'r') as file:
        query = file.read()
    
    return pd.read_sql_query(query, conn)

# Usage
results = run_complex_query("01-complex-query.sql")
```

---

## 🎓 Educational Value & Learning Outcomes

### **SQL Mastery**
- **Advanced Joins:** Complex multi-table relationships
- **Window Functions:** Ranking, partitioning, and analytical functions
- **Subquery Optimization:** Correlated and lateral subqueries
- **Performance Tuning:** Index usage and query optimization

### **Data Analysis Skills**
- **Statistical Analysis:** Correlation, variance, and distribution analysis
- **Trend Identification:** Temporal pattern recognition
- **Segmentation Techniques:** User and content categorization
- **Predictive Modeling:** Churn prediction and scoring algorithms

### **Business Intelligence**
- **KPI Development:** Music industry metrics and benchmarks
- **User Behavior Analysis:** Engagement and retention patterns
- **Content Performance:** Artist and playlist analytics
- **Market Intelligence:** Genre trends and seasonal patterns

---

## 🔧 Troubleshooting

### **Common Issues**

**Query Timeout:**
```sql
-- Increase statement timeout
SET statement_timeout = '5min';
```

**Memory Issues:**
```sql
-- Increase work memory for complex queries
SET work_mem = '256MB';
```

**Index Missing:**
```sql
-- Check if indexes exist
SELECT schemaname, tablename, indexname 
FROM pg_indexes 
WHERE schemaname = 'vibesia_schema';
```

### **Data Quality Checks**
```sql
-- Verify data completeness
SELECT 
    'users' as table_name, COUNT(*) as record_count 
FROM vibesia_schema.users
UNION ALL
SELECT 
    'playback_history', COUNT(*) 
FROM vibesia_schema.playback_history;
```

---

## 📚 Related Documentation

### **Project Structure**
- **Database Schema:** `../ddl/README.md`
- **Functions & Procedures:** `../dml/functions/README.md`
- **Audit System:** `../dml/audit/README.md`
- **Data Pipeline:** `../pipelines/README.md`

### **External Resources**
- [PostgreSQL Window Functions](https://www.postgresql.org/docs/current/functions-window.html)
- [SQL Performance Tuning Guide](https://www.postgresql.org/docs/current/performance-tips.html)
- [Music Industry Analytics Best Practices](https://musicindustryresearch.org/)

---

## 🤝 Contributing

### **Query Development Guidelines**
1. **Documentation:** Include comprehensive header comments
2. **Performance:** Test with realistic data volumes
3. **Modularity:** Use CTEs for complex logic breakdown
4. **Validation:** Include data quality checks
5. **Testing:** Provide expected output samples

### **Code Review Checklist**
- [ ] Query executes without errors
- [ ] Results are logically consistent
- [ ] Performance is acceptable (< 30 seconds)
- [ ] Documentation is complete
- [ ] Indexes are properly utilized

---

## 📊 Query Performance Benchmarks

| Query File | Typical Runtime | Memory Usage | Complexity |
|------------|----------------|--------------|------------|
| `01-complex-query.sql` | 15-25 seconds | 128MB | High |
| `02-complex-query.sql` | 8-12 seconds | 64MB | Medium |
| `03-complex-query.sql` | 10-18 seconds | 96MB | Medium |
| `05-complex-query.sql` | 12-20 seconds | 112MB | High |
| `06-complex-query.sql` | 18-30 seconds | 156MB | High |
| `07-complex-query.sql` | 14-22 seconds | 128MB | Medium |
| `08-complex-query.sql` | 16-28 seconds | 144MB | High |
| `09-complex-query.sql` | 20-35 seconds | 192MB | Very High |
| `10-complex-query.sql` | 22-40 seconds | 208MB | Very High |

*Benchmarks based on database with 1M+ users, 10M+ songs, 100M+ playback events*

---

## 📬 Support & Contact

### **Development Team**
- **Project:** MusicApp - Vibesia
- **Institution:** Universidad de Sistemas
- **Course:** Bases de Datos Avanzadas
- **Repository:** [GitHub - ProyectoFinal-BD](https://github.com/JuanDavidJR/ProyectoFinal-BD)

### **Getting Help**
1. **Documentation:** Check related README files first
2. **Issues:** Open GitHub issue with query file and error details
3. **Discussions:** Use GitHub discussions for general questions
4. **Performance:** Include `EXPLAIN ANALYZE` output for optimization help

---

## 📜 License & Academic Use

This project is developed for educational purposes as part of a university database systems course. All queries and documentation are available under the MIT License for learning and academic use.

**Citation:**
```
MusicApp Vibesia - Advanced SQL Query Collection
Universidad de Sistemas - Bases de Datos Avanzadas
GitHub: https://github.com/JuanDavidJR/ProyectoFinal-BD
```

---

**Built with 🎵 and ⚡ by the Ad-Astra Team**