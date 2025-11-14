/**
 * Скрипт для программной настройки Directus
 * Использование: node setup-directus.js
 */

const axios = require('axios');
const fs = require('fs');

const DIRECTUS_URL = process.env.DIRECTUS_URL || 'http://localhost:8055';
const ADMIN_EMAIL = process.env.ADMIN_EMAIL || 'admin@balancepsy.com';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'Aldik07bak!';

let accessToken = null;

// Аутентификация
async function login() {
  try {
    const response = await axios.post(`${DIRECTUS_URL}/auth/login`, {
      email: ADMIN_EMAIL,
      password: ADMIN_PASSWORD
    });
    accessToken = response.data.data.access_token;
    console.log('✅ Authenticated successfully');
    return accessToken;
  } catch (error) {
    console.error('❌ Authentication failed:', error.response?.data || error.message);
    process.exit(1);
  }
}

// Проверка существования коллекции
async function checkCollection(collectionName) {
  try {
    await axios.get(`${DIRECTUS_URL}/collections/${collectionName}`, {
      headers: { Authorization: `Bearer ${accessToken}` }
    });
    return true;
  } catch (error) {
    return false;
  }
}

// Создание/обновление коллекции articles
async function setupArticlesCollection() {
  const exists = await checkCollection('articles');
  
  if (exists) {
    console.log('ℹ️  Collection "articles" already exists. Updating fields...');
  } else {
    console.log('📦 Creating collection "articles"...');
    try {
      await axios.post(`${DIRECTUS_URL}/collections`, {
        collection: 'articles',
        meta: {
          icon: 'article',
          note: 'Content management for BalancePsy articles',
          display_template: '{{title}}',
          archive_field: 'status',
          archive_value: 'archived',
          unarchive_value: 'draft'
        },
        schema: {
          name: 'articles'
        },
        fields: [
          {
            field: 'id',
            type: 'integer',
            meta: { hidden: true, interface: 'input', readonly: true },
            schema: { is_primary_key: true, has_auto_increment: true }
          }
        ]
      }, {
        headers: { Authorization: `Bearer ${accessToken}` }
      });
      console.log('✅ Collection "articles" created');
    } catch (error) {
      console.error('❌ Failed to create collection:', error.response?.data || error.message);
      return;
    }
  }

  // Добавление/обновление полей
  const fields = [
    {
      field: 'status',
      type: 'string',
      schema: { default_value: 'draft', max_length: 20 },
      meta: {
        width: 'full',
        interface: 'select-dropdown',
        options: {
          choices: [
            { text: 'Draft', value: 'draft' },
            { text: 'Published', value: 'published' },
            { text: 'Archived', value: 'archived' }
          ]
        }
      }
    },
    {
      field: 'title',
      type: 'string',
      schema: { max_length: 255, is_nullable: false },
      meta: { width: 'full', interface: 'input', required: true }
    },
    {
      field: 'slug',
      type: 'string',
      schema: { max_length: 255, is_unique: true, is_nullable: false },
      meta: { width: 'full', interface: 'input', required: true }
    },
    {
      field: 'excerpt',
      type: 'text',
      meta: { width: 'full', interface: 'input-multiline' }
    },
    {
      field: 'content',
      type: 'text',
      meta: { width: 'full', interface: 'input-rich-text-html' }
    },
    {
      field: 'category',
      type: 'string',
      schema: { max_length: 50, is_nullable: false },
      meta: {
        width: 'half',
        interface: 'select-dropdown',
        required: true,
        options: {
          choices: [
            { text: 'Эмоции', value: 'emotions' },
            { text: 'Самопомощь', value: 'self_help' },
            { text: 'Отношения', value: 'relationships' },
            { text: 'Стресс', value: 'stress' },
            { text: 'Другое', value: 'other' }
          ]
        }
      }
    },
    {
      field: 'read_time',
      type: 'integer',
      meta: { width: 'half', interface: 'input' }
    },
    {
      field: 'image_url',
      type: 'string',
      schema: { max_length: 500 },
      meta: { width: 'full', interface: 'input' }
    },
    {
      field: 'created_at',
      type: 'timestamp',
      schema: { default_value: 'CURRENT_TIMESTAMP' },
      meta: { interface: 'datetime', readonly: true, special: ['date-created'] }
    },
    {
      field: 'updated_at',
      type: 'timestamp',
      schema: { default_value: 'CURRENT_TIMESTAMP' },
      meta: { interface: 'datetime', readonly: true, special: ['date-updated'] }
    }
  ];

  for (const field of fields) {
    try {
      await axios.patch(
        `${DIRECTUS_URL}/fields/articles/${field.field}`,
        field,
        { headers: { Authorization: `Bearer ${accessToken}` } }
      );
      console.log(`✅ Field "${field.field}" updated`);
    } catch (error) {
      // Поле не существует, создаем
      try {
        await axios.post(
          `${DIRECTUS_URL}/fields/articles`,
          field,
          { headers: { Authorization: `Bearer ${accessToken}` } }
        );
        console.log(`✅ Field "${field.field}" created`);
      } catch (createError) {
        console.error(`❌ Failed to create field "${field.field}":`, createError.response?.data || createError.message);
      }
    }
  }
}

// Настройка прав для Public роли
async function setupPublicPermissions() {
  console.log('🔒 Setting up public permissions...');
  
  try {
    // Получаем Public роль (null = public)
    const response = await axios.post(
      `${DIRECTUS_URL}/permissions`,
      {
        role: null,
        collection: 'articles',
        action: 'read',
        fields: ['id', 'status', 'title', 'slug', 'excerpt', 'content', 'category', 'read_time', 'image_url', 'created_at'],
        permissions: {
          status: { _eq: 'published' }
        }
      },
      { headers: { Authorization: `Bearer ${accessToken}` } }
    );
    console.log('✅ Public read permissions created');
  } catch (error) {
    if (error.response?.status === 400) {
      console.log('ℹ️  Public permissions already exist');
    } else {
      console.error('❌ Failed to set permissions:', error.response?.data || error.message);
    }
  }
}

// Главная функция
async function main() {
  console.log('🚀 Starting Directus setup...\n');
  
  await login();
  await setupArticlesCollection();
  await setupPublicPermissions();
  
  console.log('\n✨ Directus setup completed!');
  console.log(`\n📍 Admin Panel: ${DIRECTUS_URL}`);
  console.log(`📍 API Endpoint: ${DIRECTUS_URL}/items/articles`);
}

main().catch(error => {
  console.error('❌ Setup failed:', error);
  process.exit(1);
});