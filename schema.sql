-- ============================================
-- 1. ПОЛЬЗОВАТЕЛИ (базовая таблица)
-- ============================================
CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    avatar_url VARCHAR(512),
    role VARCHAR(20) NOT NULL DEFAULT 'CLIENT', -- CLIENT, PSYCHOLOGIST, ADMIN
    is_active BOOLEAN NOT NULL DEFAULT true,
    email_verified BOOLEAN NOT NULL DEFAULT false,
    parent_email VARCHAR(255),
    parent_email_verified BOOLEAN DEFAULT false,
    gender VARCHAR(10), -- male, female, other
    registration_goal TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    CONSTRAINT chk_role CHECK (
        role IN (
            'CLIENT',
            'PSYCHOLOGIST',
            'ADMIN'
        )
    ),
    CONSTRAINT chk_gender CHECK (
        gender IN ('male', 'female', 'other')
    )
);

CREATE INDEX idx_users_email ON users (email);

CREATE INDEX idx_users_role ON users (role);

-- ============================================
-- 2. ИНТЕРЕСЫ ПОЛЬЗОВАТЕЛЕЙ
-- ============================================
CREATE TABLE user_interests (
    user_id BIGINT NOT NULL,
    interest_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (user_id, interest_name),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- ============================================
-- 3. ПРОФИЛИ ПСИХОЛОГОВ
-- ============================================
CREATE TABLE psychologist_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,

-- Профессиональная информация
specialization VARCHAR(255) NOT NULL,
experience_years INTEGER NOT NULL DEFAULT 0,
bio TEXT NOT NULL,
education TEXT NOT NULL,
certificate_url VARCHAR(512),
avatar_file VARCHAR(64),

-- Статистика
rating DOUBLE PRECISION DEFAULT 0.0,
reviews_count INTEGER DEFAULT 0,
total_sessions INTEGER DEFAULT 0,

-- Доступность / модерация
is_available BOOLEAN NOT NULL DEFAULT true,
is_verified BOOLEAN NOT NULL DEFAULT false,
verification_notes TEXT,

-- Финансы


hourly_rate NUMERIC(38,2),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_rating CHECK (rating >= 0 AND rating <= 5)
);

CREATE INDEX idx_psychologist_verified ON psychologist_profiles (is_verified, is_available);

CREATE INDEX idx_psychologist_rating ON psychologist_profiles (rating DESC);

-- ============================================
-- 4. ПОДХОДЫ ПСИХОЛОГОВ
-- ============================================
CREATE TABLE psychologist_approaches (
    profile_id BIGINT NOT NULL,
    approach VARCHAR(100) NOT NULL,
    PRIMARY KEY (profile_id, approach),
    FOREIGN KEY (profile_id) REFERENCES psychologist_profiles (id) ON DELETE CASCADE
);

-- ============================================
-- 5. РАСПИСАНИЕ ПСИХОЛОГОВ
-- ============================================
CREATE TABLE psychologist_schedules (
    id BIGSERIAL PRIMARY KEY,
    psychologist_id BIGINT NOT NULL,
    day_of_week INTEGER NOT NULL, -- 1=Monday, 7=Sunday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (psychologist_id) REFERENCES psychologist_profiles (id) ON DELETE CASCADE,
    CONSTRAINT chk_day_of_week CHECK (day_of_week BETWEEN 1 AND 7),
    CONSTRAINT chk_time_range CHECK (end_time > start_time)
);

-- ============================================
-- 6. ЗАПИСИ НА СЕССИИ
-- ============================================
CREATE TABLE appointments (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL,
    psychologist_id BIGINT NOT NULL,

-- Время и дата
appointment_date DATE NOT NULL,
start_time TIME NOT NULL,
end_time TIME NOT NULL,

-- Формат и статус
format VARCHAR(20) NOT NULL DEFAULT 'VIDEO', -- video, chat, audio
status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, CONFIRMED, COMPLETED, CANCELLED

-- Детали
issue_description TEXT, notes TEXT, price DECIMAL(10, 2) NOT NULL,

-- Временные метки


created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    
    FOREIGN KEY (client_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (psychologist_id) REFERENCES psychologist_profiles(id) ON DELETE CASCADE,
    CONSTRAINT chk_format CHECK (format IN ('VIDEO', 'CHAT', 'AUDIO')),
    CONSTRAINT chk_status CHECK (status IN ('PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_SHOW'))
);

CREATE INDEX idx_appointments_client ON appointments (client_id);

CREATE INDEX idx_appointments_psychologist ON appointments (psychologist_id);

CREATE INDEX idx_appointments_date ON appointments (appointment_date);

CREATE INDEX idx_appointments_status ON appointments (status);

ALTER TABLE appointments
ADD COLUMN started_at TIMESTAMP,
ADD COLUMN actual_duration INTEGER;

-- ============================================
-- 7. ОТЗЫВЫ
-- ============================================
CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    appointment_id BIGINT NOT NULL UNIQUE,
    client_id BIGINT NOT NULL,
    psychologist_id BIGINT NOT NULL,
    rating INTEGER NOT NULL,
    review_text TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments (id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (psychologist_id) REFERENCES psychologist_profiles (id) ON DELETE CASCADE,
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
);

CREATE INDEX idx_reviews_psychologist ON reviews (psychologist_id);
-- ============================================
-- 11. статья
-- ============================================
CREATE TABLE articles (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT,
    author_id BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

-- Новые поля из живой БД


view_count INTEGER DEFAULT 0,
    slug VARCHAR(255),
    excerpt TEXT,
    read_time INTEGER,
    thumbnail_image UUID,
    header_image UUID,
    status VARCHAR(255),
    category VARCHAR(255),

    CONSTRAINT fk_articles_author
        FOREIGN KEY (author_id)
        REFERENCES users (user_id)
        ON DELETE SET NULL
);

CREATE INDEX idx_articles_status ON articles (status);

CREATE INDEX idx_articles_author ON articles (author_id);

-- ============================================
-- 8. ВЕРИФИКАЦИЯ EMAIL
-- ============================================
CREATE TABLE email_verifications (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    code VARCHAR(6) NOT NULL,
    is_parent_email BOOLEAN NOT NULL DEFAULT false,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    purpose VARCHAR(50) NOT NULL DEFAULT 'REGISTRATION', -- REGISTRATION, PASSWORD_RESET
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP,
    CONSTRAINT chk_purpose CHECK (
        purpose IN (
            'REGISTRATION',
            'PASSWORD_RESET'
        )
    )
);

CREATE INDEX idx_email_verifications_email ON email_verifications (email);

CREATE INDEX idx_email_verifications_expires ON email_verifications (expires_at);

-- ============================================
-- 9. ОТЧЁТЫ ПО СЕССИЯМ
-- ============================================
CREATE TABLE reports (
    id BIGSERIAL PRIMARY KEY,
    appointment_id BIGINT NOT NULL UNIQUE,
    psychologist_id BIGINT NOT NULL,
    client_id BIGINT NOT NULL,

-- Содержимое отчёта
session_theme VARCHAR(500) NOT NULL,
session_description TEXT NOT NULL,
recommendations TEXT,

-- Статус отчёта
is_completed BOOLEAN NOT NULL DEFAULT false,

-- Временные метки


created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    FOREIGN KEY (psychologist_id) REFERENCES psychologist_profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_reports_psychologist ON reports (psychologist_id);

CREATE INDEX idx_reports_completed ON reports (is_completed);
-- ============================================
-- 9. ЧАТЫ/СООБЩЕНИЯ (для будущего)
-- ============================================
CREATE TABLE chat_rooms (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL,
    psychologist_id BIGINT NOT NULL,
    appointment_id BIGINT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- новые поля для превью последнего сообщения
    last_message_at TIMESTAMP,
    last_message_text TEXT,
    FOREIGN KEY (client_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (psychologist_id) REFERENCES psychologist_profiles (id) ON DELETE CASCADE,
    FOREIGN KEY (appointment_id) REFERENCES appointments (id) ON DELETE SET NULL,
    UNIQUE (client_id, psychologist_id)
);

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    chat_room_id BIGINT NOT NULL,
    sender_id BIGINT NOT NULL,

-- текст сообщения
message_text TEXT,

-- статус прочтения
is_read BOOLEAN NOT NULL DEFAULT false,
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
read_at TIMESTAMP,

-- тип сообщения
message_type VARCHAR(20) NOT NULL DEFAULT 'text',

-- вложения (файлы, картинки, голосовые, видео)
attachment_url VARCHAR(512),
attachment_type VARCHAR(50),
attachment_name VARCHAR(255),
attachment_size BIGINT,
voice_duration INTEGER,

-- редактирование / удаление


edited_at TIMESTAMP,
    is_deleted BOOLEAN NOT NULL DEFAULT false,

    FOREIGN KEY (chat_room_id) REFERENCES chat_rooms (id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users (user_id) ON DELETE CASCADE,

    CONSTRAINT chk_message_type CHECK (
        message_type IN ('TEXT', 'VOICE', 'FILE', 'IMAGE', 'VIDEO', 'SYSTEM')
    )
);

-- Индексы для чатов и сообщений
CREATE INDEX idx_messages_chat_room ON messages (chat_room_id);

CREATE INDEX idx_messages_unread ON messages (chat_room_id, is_read);

CREATE INDEX idx_messages_created_at ON messages (created_at DESC);

CREATE INDEX idx_messages_sender ON messages (sender_id);

CREATE INDEX idx_chat_rooms_last_message ON chat_rooms (last_message_at DESC);

CREATE INDEX idx_messages_unread_by_user ON messages (
    chat_room_id,
    sender_id,
    is_read
);

-- Триггер для обновления информации о последнем сообщении в chat_rooms
CREATE OR REPLACE FUNCTION update_chat_room_last_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE chat_rooms
    SET 
        last_message_at = NEW.created_at,
        last_message_text = CASE 
            WHEN NEW.message_type = 'TEXT' THEN LEFT(NEW.message_text, 100)
            WHEN NEW.message_type = 'VOICE' THEN '🎤 Голосовое сообщение'
            WHEN NEW.message_type = 'IMAGE' THEN '🖼️ Изображение'
            WHEN NEW.message_type = 'FILE' THEN '📎 Файл'
            WHEN NEW.message_type = 'VIDEO' THEN '📹 Видеосообщение'
            ELSE 'Сообщение'
        END
    WHERE id = NEW.chat_room_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_chat_room_last_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_chat_room_last_message();

-- Индикаторы "печатает..."
CREATE TABLE chat_typing_indicators (
    id BIGSERIAL PRIMARY KEY,
    chat_room_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (chat_room_id) REFERENCES chat_rooms (id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    UNIQUE (chat_room_id, user_id)
);

CREATE INDEX idx_typing_indicators_time ON chat_typing_indicators (started_at);

-- ============================================
-- 10. ТРИГГЕРЫ ДЛЯ АВТООБНОВЛЕНИЯ
-- ============================================

-- Обновление updated_at для users
CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_users_updated_at();

-- Обновление updated_at для psychologist_profiles
CREATE OR REPLACE FUNCTION update_psychologist_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_psychologist_profiles_updated_at
BEFORE UPDATE ON psychologist_profiles
FOR EACH ROW
EXECUTE FUNCTION update_psychologist_profiles_updated_at();

-- Обновление рейтинга психолога при добавлении отзыва
CREATE OR REPLACE FUNCTION update_psychologist_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE psychologist_profiles
    SET 
        rating = (SELECT AVG(rating) FROM reviews WHERE psychologist_id = NEW.psychologist_id),
        reviews_count = (SELECT COUNT(*) FROM reviews WHERE psychologist_id = NEW.psychologist_id)
    WHERE id = NEW.psychologist_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_psychologist_rating
AFTER INSERT OR UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_psychologist_rating();

-- Функция проверки переходов статуса
CREATE OR REPLACE FUNCTION check_appointment_status_transition()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'COMPLETED' AND NEW.status != 'COMPLETED' THEN
        RAISE EXCEPTION 'Cannot change status of completed appointment';
    END IF;

    IF OLD.status = 'CANCELLED' AND NEW.status != 'CANCELLED' THEN
        RAISE EXCEPTION 'Cannot change status of cancelled appointment';
    END IF;

    IF NEW.status = 'IN_PROGRESS' AND OLD.status != 'IN_PROGRESS' THEN
        NEW.started_at = CURRENT_TIMESTAMP;
    END IF;

    IF NEW.status = 'COMPLETED' AND OLD.status != 'COMPLETED' THEN
        IF NEW.started_at IS NOT NULL THEN
            NEW.actual_duration = EXTRACT(EPOCH FROM (NEW.completed_at - NEW.started_at)) / 60;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Триггер для проверки переходов статуса в appointments
CREATE TRIGGER trg_appointment_status_check
BEFORE UPDATE ON appointments
FOR EACH ROW
EXECUTE FUNCTION check_appointment_status_transition();

--Индексы для оптимизации запросов по статусу и дате
CREATE INDEX idx_appointments_status_date ON appointments (status, appointment_date)
WHERE
    status IN ('CONFIRMED', 'IN_PROGRESS');

CREATE INDEX idx_appointments_started_at ON appointments (started_at)
WHERE
    started_at IS NOT NULL;

-- ============================================
-- 11. ВИДЫ
-- ============================================
CREATE OR REPLACE VIEW v_psychologist_active_sessions AS
SELECT
    a.id,
    a.psychologist_id,
    a.client_id,
    u.full_name AS client_name,
    a.appointment_date,
    a.start_time,
    a.end_time,
    a.format,
    a.status,
    a.started_at,
    a.actual_duration,
    CASE
        WHEN a.status = 'IN_PROGRESS' THEN 'in_progress'
        WHEN a.appointment_date = CURRENT_DATE
        AND a.start_time <= CURRENT_TIME THEN 'past'
        WHEN a.appointment_date = CURRENT_DATE
        AND a.start_time > CURRENT_TIME
        AND (a.start_time - LOCALTIME) < INTERVAL '30 minutes' THEN 'soon'
        WHEN a.appointment_date = CURRENT_DATE THEN 'today'
        WHEN a.appointment_date < CURRENT_DATE THEN 'past'
        ELSE 'upcoming'
    END AS session_status
FROM appointments a
    JOIN users u ON u.user_id = a.client_id
WHERE
    a.status IN ('CONFIRMED', 'IN_PROGRESS')
ORDER BY a.appointment_date, a.start_time;

-- ============================================
-- 12. ТРИГГЕРЫ ДЛЯ АВТОСОЗДАНИЯ ОТЧЁТОВ
-- ============================================

CREATE OR REPLACE FUNCTION auto_create_report_placeholder()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'COMPLETED' AND OLD.status != 'COMPLETED' THEN
        IF NOT EXISTS (
            SELECT 1 FROM reports WHERE appointment_id = NEW.id
        ) THEN
            INSERT INTO reports (
                appointment_id,
                psychologist_id,
                client_id,
                session_theme,
                session_description,
                is_completed,
                created_at
            ) VALUES (
                NEW.id,
                NEW.psychologist_id,
                NEW.client_id,
                'Требуется заполнить',
                'Отчёт по сессии от ' || NEW.appointment_date::TEXT,
                false,
                CURRENT_TIMESTAMP
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Триггер для авто-создания отчёта при смене статуса на COMPLETED
CREATE TRIGGER trg_auto_create_report
AFTER UPDATE ON appointments
FOR EACH ROW
WHEN (NEW.status = 'COMPLETED')
EXECUTE FUNCTION auto_create_report_placeholder();

-- ============================================
-- 13. ОБНОВЛЕНИЕ СТАТУСА "НЕ ЯВИЛСЯ"
-- ============================================
UPDATE appointments
SET
    status = 'NO_SHOW',
    cancellation_reason = 'Автоматическая отметка — клиент не явился'
WHERE
    status = 'CONFIRMED'
    AND appointment_date < CURRENT_DATE
    AND completed_at IS NULL;

--- ============================================
-- 14. КОММЕНТАРИИ К НОВЫМ ПОЛЯМ В APPOINTMENTS
-- ============================================
COMMENT ON COLUMN appointments.started_at IS 'Фактическое время начала сессии';

COMMENT ON COLUMN appointments.actual_duration IS 'Фактическая длительность сессии (минуты)';

-- ============================================
-- 15. ФУНКЦИЯ ДЛЯ СТАТИСТИКИ ПСИХОЛОГА
-- ============================================
CREATE OR REPLACE FUNCTION get_psychologist_stats(p_psychologist_id BIGINT)
RETURNS TABLE (
    today_sessions INTEGER,
    pending_requests INTEGER,
    week_revenue NUMERIC,
    total_completed INTEGER,
    avg_session_duration INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) FILTER (
            WHERE appointment_date = CURRENT_DATE 
              AND status NOT IN ('CANCELLED', 'NO_SHOW')
        )::INTEGER,

        COUNT(*) FILTER (WHERE status = 'PENDING')::INTEGER,

        COALESCE(SUM(price) FILTER (
            WHERE status = 'COMPLETED'
              AND completed_at >= CURRENT_DATE - INTERVAL '7 days'
        ), 0),

        COUNT(*) FILTER (WHERE status = 'COMPLETED')::INTEGER,

        AVG(actual_duration) FILTER (
            WHERE actual_duration IS NOT NULL
        )::INTEGER
    FROM appointments
    WHERE psychologist_id = p_psychologist_id;
END;
$$ LANGUAGE plpgsql;

--- ============================================
-- 16. ИСПРАВЛЕНИЕ ФУНКЦИИ АВТОСОЗДАНИЯ ОТЧЁТОВ
-- ============================================
CREATE OR REPLACE FUNCTION auto_create_report_placeholder()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO reports (
        appointment_id,
        psychologist_id,
        client_id,
        session_theme,
        session_description,
        is_completed,
        created_at,
        updated_at  -- Добавили это поле
    ) VALUES (
        NEW.id,
        NEW.psychologist_id,
        NEW.client_id,
        'Требуется заполнить',
        'Отчёт по сессии от ' || NEW.appointment_date::TEXT,
        false,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP  -- Добавили значение
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Миграция для диагностики и туториала
-- ============================================

-- 1. Добавление полей для соглашения в users
ALTER TABLE users
ADD COLUMN agreement_accepted BOOLEAN DEFAULT false,
ADD COLUMN agreement_version VARCHAR(20),
ADD COLUMN agreement_accepted_at TIMESTAMP;

COMMENT ON COLUMN users.agreement_accepted IS 'Принял ли пользователь соглашение';

COMMENT ON COLUMN users.agreement_version IS 'Версия принятого соглашения';

COMMENT ON COLUMN users.agreement_accepted_at IS 'Дата и время принятия соглашения';

-- 2. Добавление поля для завершения туториала
ALTER TABLE users
ADD COLUMN tutorial_completed BOOLEAN DEFAULT false,
ADD COLUMN tutorial_completed_at TIMESTAMP;

COMMENT ON COLUMN users.tutorial_completed IS 'Завершил ли пользователь туториал';

COMMENT ON COLUMN users.tutorial_completed_at IS 'Дата и время завершения туториала';

-- 3. Таблица для хранения результатов диагностики
CREATE TABLE diagnostic_results (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,

-- Шкала PHQ-9 (Депрессия)
phq9_score INTEGER, phq9_raw_answers JSONB, phq9_interpretation TEXT,

-- Шкала GAD-7 (Тревога)
gad7_score INTEGER, gad7_raw_answers JSONB, gad7_interpretation TEXT,

-- Тест EAT-26 (РПП)
eat26_score INTEGER,
eat26_raw_answers JSONB,
eat26_interpretation TEXT,

-- BDD Questionnaire (Дисморфофобия)
bdd_positive BOOLEAN, bdd_raw_answers JSONB, bdd_interpretation TEXT,

-- Перфекционизм
perfectionism_score INTEGER,
perfectionism_raw_answers JSONB,
perfectionism_interpretation TEXT,

-- Метаданные


completed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_diagnostic_results_user ON diagnostic_results (user_id);

CREATE INDEX idx_diagnostic_results_completed ON diagnostic_results (completed_at DESC);

COMMENT ON
TABLE diagnostic_results IS 'Результаты психологической диагностики пользователей';

COMMENT ON COLUMN diagnostic_results.phq9_score IS 'Суммарный балл по шкале PHQ-9 (0-27)';

COMMENT ON COLUMN diagnostic_results.gad7_score IS 'Суммарный балл по шкале GAD-7 (0-21)';

COMMENT ON COLUMN diagnostic_results.eat26_score IS 'Суммарный балл по тесту EAT-26';

COMMENT ON COLUMN diagnostic_results.bdd_positive IS 'Положительный скрининг на BDD';

COMMENT ON COLUMN diagnostic_results.perfectionism_score IS 'Суммарный балл по шкале перфекционизма (12-60)';

-- 4. Таблица для управления туториальным контентом
CREATE TABLE tutorial_content (
    id BIGSERIAL PRIMARY KEY,
    content_type VARCHAR(20) NOT NULL, -- video, article, meditation
    title VARCHAR(255) NOT NULL,
    description TEXT,
    content_url VARCHAR(512),
    content_text TEXT,
    audio_url VARCHAR(512),
    duration_seconds INTEGER,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_content_type CHECK (
        content_type IN (
            'video',
            'article',
            'meditation'
        )
    )
);

CREATE INDEX idx_tutorial_content_active ON tutorial_content (is_active, sort_order);

COMMENT ON
TABLE tutorial_content IS 'Контент для туториала после диагностики';

COMMENT ON COLUMN tutorial_content.content_type IS 'Тип контента: video, article, meditation';

-- 5. Триггер для auto-update updated_at в diagnostic_results
CREATE OR REPLACE FUNCTION update_diagnostic_results_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_diagnostic_results_updated_at
BEFORE UPDATE ON diagnostic_results
FOR EACH ROW
EXECUTE FUNCTION update_diagnostic_results_updated_at();

-- 6. Триггер для auto-update updated_at в tutorial_content
CREATE OR REPLACE FUNCTION update_tutorial_content_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tutorial_content_updated_at
BEFORE UPDATE ON tutorial_content
FOR EACH ROW
EXECUTE FUNCTION update_tutorial_content_updated_at();

-- 7. Вставка начального контента для туториала
INSERT INTO
    tutorial_content (
        content_type,
        title,
        description,
        content_url,
        sort_order,
        is_active
    )
VALUES (
        'video',
        'Что такое BalancePsy',
        'Вводное видео о платформе и её возможностях',
        'http://localhost:8055/assets/a68b7ab4-035f-4b74-bд91-a5684067be29',
        1,
        true
    ),
    (
        'article',
        'Как BalancePsy помогает',
        'Статья о научных основах и методиках приложения',
        NULL,
        2,
        true
    ),
    (
        'meditation',
        'Медитация осознанности',
        'Практика для начинающих (5 минут)',
        'http://localhost:8055/assets/a967cab0-2b09-457f-a1fc-444814617936',
        3,
        true
    );

-- 8. Добавление функции для получения последней диагностики пользователя
CREATE OR REPLACE FUNCTION get_latest_diagnostic(p_user_id BIGINT)
RETURNS TABLE (
    diagnostic_id BIGINT,
    phq9_score INTEGER,
    gad7_score INTEGER,
    eat26_score INTEGER,
    bdd_positive BOOLEAN,
    perfectionism_score INTEGER,
    completed_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        id,
        phq9_score,
        gad7_score,
        eat26_score,
        bdd_positive,
        perfectionism_score,
        diagnostic_results.completed_at
    FROM diagnostic_results
    WHERE user_id = p_user_id
    ORDER BY completed_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- X. АКТИВНОСТЬ ПОЛЬЗОВАТЕЛЯ (STREAK / ПРОГРЕСС)
-- ============================================
CREATE TABLE IF NOT EXISTS user_activity (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,
    activity_type VARCHAR(50) NOT NULL, -- 'login', 'session', 'goal_completed' и т.п.
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (
        user_id,
        activity_date,
        activity_type
    )
);

CREATE INDEX IF NOT EXISTS idx_user_activity_user_date ON user_activity (user_id, activity_date DESC);

CREATE INDEX IF NOT EXISTS idx_user_activity_type ON user_activity (activity_type);

COMMENT ON
TABLE user_activity IS 'Трекинг активности пользователя для расчета streak и прогресса';

COMMENT ON COLUMN user_activity.activity_type IS 'Тип активности: login, session, goal_completed и т.п.';

-- ============================================
-- X. ЦЕЛИ КЛИЕНТА (ДЛЯ БЛОКА "ПРОГРЕСС")
-- ============================================
CREATE TABLE IF NOT EXISTS client_goals (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    goal_title VARCHAR(200) NOT NULL,
    goal_description TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    target_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_client_goals_user ON client_goals (user_id);

CREATE INDEX IF NOT EXISTS idx_client_goals_completed ON client_goals (is_completed);

COMMENT ON
TABLE client_goals IS 'Цели клиентов для отображения прогресса в профиле';

-- ============================================
-- X. ПРОСМОТРЫ ПРОФИЛЕЙ ПСИХОЛОГОВ
-- ============================================
CREATE TABLE IF NOT EXISTS profile_views (
    id BIGSERIAL PRIMARY KEY,
    psychologist_id BIGINT NOT NULL REFERENCES psychologist_profiles (id) ON DELETE CASCADE,
    viewer_id BIGINT REFERENCES users (user_id) ON DELETE SET NULL,
    viewer_ip VARCHAR(45),
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_profile_views_psychologist_date ON profile_views (
    psychologist_id,
    viewed_at DESC
);

CREATE INDEX IF NOT EXISTS idx_profile_views_viewer ON profile_views (viewer_id);

COMMENT ON
TABLE profile_views IS 'Просмотры профилей психологов для блока статистики и аналитики';

-- ============================================
-- X. VIEW ДЛЯ БЛОКА "ПРОГРЕСС" КЛИЕНТА
-- ============================================
-- Использует:
--   users              (только роль CLIENT)
--   appointments       (статусы, даты, цена)
--   reviews            (оценки сессий)
--   user_activity      (активные дни)
--   client_goals       (цели клиента)
-- Даёт агрегированную статистику по каждому клиенту.

CREATE OR REPLACE VIEW client_progress AS SELECT u.user_id,

-- Кол-во завершённых сессий
COUNT(
    DISTINCT (
        CASE
            WHEN a.status = 'COMPLETED' THEN a.id
        END
    )
) AS completed_sessions,

-- Всего сессий (кроме отменённых)
COUNT(
    DISTINCT (
        CASE
            WHEN a.status IN (
                'CONFIRMED',
                'IN_PROGRESS',
                'COMPLETED'
            ) THEN a.id
        END
    )
) AS total_sessions,

-- Будущие сессии
COUNT(
    DISTINCT (
        CASE
            WHEN a.status IN ('CONFIRMED', 'IN_PROGRESS')
            AND (
                a.appointment_date > CURRENT_DATE
                OR (
                    a.appointment_date = CURRENT_DATE
                    AND a.start_time >= CURRENT_TIME
                )
            ) THEN a.id
        END
    )
) AS upcoming_sessions,

-- Посещаемость
COALESCE(
    ROUND(
        100.0 * COUNT(
            DISTINCT (
                CASE
                    WHEN a.status = 'COMPLETED' THEN a.id
                END
            )
        ) / NULLIF(
            COUNT(
                DISTINCT (
                    CASE
                        WHEN a.status IN (
                            'CONFIRMED',
                            'COMPLETED',
                            'NO_SHOW'
                        ) THEN a.id
                    END
                )
            ),
            0
        ),
        2
    ),
    0
) AS attendance_rate,

-- Активные дни за последние 30 дней
(
    SELECT COUNT(DISTINCT ua.activity_date)
    FROM user_activity ua
    WHERE
        ua.user_id = u.user_id
        AND ua.activity_date >= CURRENT_DATE - INTERVAL '30 days'
) AS active_days_last_30,

-- Цели
(
    SELECT COUNT(*)
    FROM client_goals cg
    WHERE
        cg.user_id = u.user_id
        AND cg.is_completed = TRUE
) AS completed_goals,
(
    SELECT COUNT(*)
    FROM client_goals cg
    WHERE
        cg.user_id = u.user_id
) AS total_goals,

-- Средний рейтинг
COALESCE(AVG(r.rating), 0) AS average_session_rating,

-- Дата последней завершённой сессии
MAX(
    CASE
        WHEN a.status = 'COMPLETED' THEN a.completed_at
    END
) AS last_session_date,

-- Ближайшая сессия

MIN(
        CASE 
            WHEN a.status IN ('CONFIRMED','IN_PROGRESS')
             AND (a.appointment_date::timestamp + a.start_time) > CURRENT_TIMESTAMP
            THEN a.appointment_date::timestamp + a.start_time 
        END
    ) AS next_session_date

FROM
    users u
    LEFT JOIN appointments a ON u.user_id = a.client_id
    LEFT JOIN reviews r ON a.id = r.appointment_id
WHERE
    u.role = 'CLIENT'
GROUP BY
    u.user_id;

COMMENT ON VIEW client_progress IS 'Агрегированная статистика прогресса клиента для вывода в профиле';

DROP VIEW IF EXISTS psychologist_statistics;

CREATE OR REPLACE VIEW psychologist_statistics AS
SELECT
    p.id AS psychologist_id,

    -- 📊 Рейтинг и отзывы
    COALESCE((
        SELECT AVG(r.rating)::float
        FROM reviews r
        WHERE r.psychologist_id = p.id
    ), 0) AS average_rating,

    COALESCE((
        SELECT COUNT(*)
        FROM reviews r
        WHERE r.psychologist_id = p.id
    ), 0) AS total_reviews,

    COALESCE((
        SELECT COUNT(*)
        FROM reviews r
        WHERE r.psychologist_id = p.id
          AND r.rating = 5
    ), 0) AS reviews_5_star,

    COALESCE((
        SELECT COUNT(*)
        FROM reviews r
        WHERE r.psychologist_id = p.id
          AND r.rating = 4
    ), 0) AS reviews_4_star,

    COALESCE((
        SELECT COUNT(*)
        FROM reviews r
        WHERE r.psychologist_id = p.id
          AND r.rating = 3
    ), 0) AS reviews_3_star,

    COALESCE((
        SELECT COUNT(*)
        FROM reviews r
        WHERE r.psychologist_id = p.id
          AND r.rating = 2
    ), 0) AS reviews_2_star,

    COALESCE((
        SELECT COUNT(*)
        FROM reviews r
        WHERE r.psychologist_id = p.id
          AND r.rating = 1
    ), 0) AS reviews_1_star,

    -- 👥 Клиенты и сессии
    COALESCE((
        SELECT COUNT(DISTINCT a.client_id)
        FROM appointments a
        WHERE a.psychologist_id = p.id
    ), 0) AS total_clients,

    COALESCE((
        SELECT COUNT(DISTINCT a.client_id)
        FROM appointments a
        WHERE a.psychologist_id = p.id
          AND a.status = 'COMPLETED'
          AND a.appointment_date >= CURRENT_DATE - INTERVAL '90 days'
    ), 0) AS active_clients,

    COALESCE((
        SELECT COUNT(*)
        FROM appointments a
        WHERE a.psychologist_id = p.id
          AND a.status = 'COMPLETED'
    ), 0) AS total_completed_sessions,

    COALESCE((
        SELECT COUNT(*)
        FROM appointments a
        WHERE a.psychologist_id = p.id
          AND a.status = 'COMPLETED'
          AND a.appointment_date >= date_trunc('month', CURRENT_DATE)
    ), 0) AS completed_sessions_this_month,

    COALESCE((
        SELECT COUNT(*)
        FROM appointments a
        WHERE a.psychologist_id = p.id
          AND a.status = 'COMPLETED'
    ), 0) AS successful_sessions, -- можно усложнить, если хочешь учитывать NO_SHOW/ CANCELLED отдельно

    -- 👁 Просмотры профиля
    COALESCE((
        SELECT COUNT(*)
        FROM profile_views v
        WHERE v.psychologist_id = p.id
          AND v.viewed_at >= CURRENT_DATE - INTERVAL '7 days'
    ), 0) AS profile_views_week,

    COALESCE((
        SELECT COUNT(*)
        FROM profile_views v
        WHERE v.psychologist_id = p.id
          AND v.viewed_at >= date_trunc('month', CURRENT_DATE)
    ), 0) AS profile_views_month,

    COALESCE((
        SELECT COUNT(*)
        FROM profile_views v
        WHERE v.psychologist_id = p.id
    ), 0) AS profile_views_total

FROM psychologist_profiles p;

COMMENT ON VIEW psychologist_statistics IS 'Агрегированная статистика психолога по сессиям, отзывам и просмотрам профиля';
