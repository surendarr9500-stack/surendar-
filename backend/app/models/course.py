from sqlalchemy import Column, String, Boolean, DateTime, Integer, Text, ForeignKey, Float
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from ..db.session import Base

class Course(Base):
    __tablename__ = "courses"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String, nullable=False)
    difficulty = Column(String, default="beginner")
    duration_minutes = Column(Integer, default=0)
    version = Column(Integer, default=1)
    is_published = Column(Boolean, default=True)
    offline_available = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Module(Base):
    __tablename__ = "modules"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    course_id = Column(String, ForeignKey("courses.id"), nullable=False, index=True)
    title = Column(String, nullable=False)
    order_index = Column(Integer, default=0)
    description = Column(Text, nullable=False)

class Lesson(Base):
    __tablename__ = "lessons"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    module_id = Column(String, ForeignKey("modules.id"), nullable=False, index=True)
    title = Column(String, nullable=False)
    type = Column(String, default="video")
    order_index = Column(Integer, default=0)
    duration_minutes = Column(Integer, default=0)
    content_path = Column(String, nullable=True)
    content_url = Column(String, nullable=True)
    is_downloaded = Column(Boolean, default=False)
    version = Column(Integer, default=1)
    checksum = Column(String, nullable=True)

class Media(Base):
    __tablename__ = "media"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    lesson_id = Column(String, ForeignKey("lessons.id"), nullable=True)
    title = Column(String, nullable=False)
    file_path = Column(String, nullable=True)
    file_url = Column(String, nullable=True)
    file_type = Column(String, nullable=False)
    file_size = Column(Integer, default=0)
    checksum = Column(String, nullable=True)
    version = Column(Integer, default=1)
    is_downloaded = Column(Boolean, default=False)
    download_progress = Column(Float, default=0.0)
    playback_position = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Document(Base):
    __tablename__ = "documents"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String, nullable=False)
    version = Column(Integer, default=1)
    category = Column(String, nullable=False)
    component_id = Column(String, nullable=True)
    language = Column(String, default="en")
    file_path = Column(String, nullable=True)
    file_url = Column(String, nullable=True)
    checksum = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    offline_available = Column(Boolean, default=False)
    fts_content = Column(Text, nullable=True)

class Quiz(Base):
    __tablename__ = "quizzes"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    course_id = Column(String, ForeignKey("courses.id"), nullable=True)
    lesson_id = Column(String, ForeignKey("lessons.id"), nullable=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    passing_score = Column(Integer, default=70)
    time_limit_minutes = Column(Integer, default=30)
    version = Column(Integer, default=1)
    is_published = Column(Boolean, default=True)

class Question(Base):
    __tablename__ = "questions"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    quiz_id = Column(String, ForeignKey("quizzes.id"), nullable=False, index=True)
    question_text = Column(Text, nullable=False)
    type = Column(String, default="multiple_choice")
    options = Column(Text, nullable=False)  # JSON string
    correct_answer = Column(String, nullable=False)
    explanation = Column(Text, nullable=True)
    order_index = Column(Integer, default=0)
    points = Column(Integer, default=1)

class QuizAttempt(Base):
    __tablename__ = "quiz_attempts"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    quiz_id = Column(String, ForeignKey("quizzes.id"), nullable=False)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    score = Column(Float, default=0.0)
    max_score = Column(Integer, default=0)
    passed = Column(Boolean, default=False)
    started_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)
    answers = Column(Text, default="{}")
    sync_status = Column(String, default="PENDING")

class Progress(Base):
    __tablename__ = "progress"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    course_id = Column(String, ForeignKey("courses.id"), nullable=False)
    lesson_id = Column(String, nullable=True)
    progress_percent = Column(Float, default=0.0)
    completed = Column(Boolean, default=False)
    last_accessed = Column(DateTime, default=datetime.utcnow)
    sync_status = Column(String, default="PENDING")
