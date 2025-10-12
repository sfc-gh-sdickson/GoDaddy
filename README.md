<img src="Snowflake_Logo.svg" width="200">

godaddy-intelligence-agent/
├── sql/
│   ├── setup/
│   │   ├── 01_database_and_schema.sql          ✅ Database, schemas, warehouse
│   │   └── 02_create_tables.sql                ✅ All table definitions
│   ├── data/
│   │   └── 03_generate_synthetic_data.sql      ✅ 2M+ rows of realistic data
│   ├── views/
│   │   ├── 04_create_views.sql                 ✅ Analytical views
│   │   └── 05_create_semantic_views.sql        ✅ Semantic views (VERIFIED)
│   ├── search/
│   │   └── 06_create_cortex_search.sql         ✅ Cortex Search services (VERIFIED)
│   ├── queries/
│   └── verification/
├── docs/
│   ├── questions.md                            ✅ 20 complex test questions
│   ├── AGENT_SETUP.md                          ✅ Complete setup guide
│   └── README.md                               ✅ Comprehensive documentation
├── scripts/
└── README.md                                    ✅ Main documentation
