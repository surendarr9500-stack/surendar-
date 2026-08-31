from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from ...db.session import get_db
from ...models.course import Course, Module, Lesson, Quiz, Question, QuizAttempt, Progress, Media, Document
from ...core.security import get_current_user_token
from datetime import datetime

router = APIRouter()

@router.get("/")
async def list_courses(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    courses = db.query(Course).all()
    return courses

@router.get("/{course_id}")
async def get_course(course_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        return {"detail": "Course not found"}
    modules = db.query(Module).filter(Module.course_id == course_id).order_by(Module.order_index).all()
    return {"course": course, "modules": modules}

@router.get("/{course_id}/modules")
async def get_course_modules(course_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    modules = db.query(Module).filter(Module.course_id == course_id).order_by(Module.order_index).all()
    return modules

@router.get("/modules/{module_id}/lessons")
async def get_module_lessons(module_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    lessons = db.query(Lesson).filter(Lesson.module_id == module_id).order_by(Lesson.order_index).all()
    return lessons

@router.get("/quizzes/")
async def list_quizzes(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    quizzes = db.query(Quiz).all()
    return quizzes

@router.get("/quizzes/{quiz_id}")
async def get_quiz(quiz_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    quiz = db.query(Quiz).filter(Quiz.id == quiz_id).first()
    if not quiz:
        return {"detail": "Quiz not found"}
    questions = db.query(Question).filter(Question.quiz_id == quiz_id).order_by(Question.order_index).all()
    return {"quiz": quiz, "questions": questions}

@router.post("/quizzes/{quiz_id}/attempts")
async def create_attempt(quiz_id: str, answers: dict, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    quiz = db.query(Quiz).filter(Quiz.id == quiz_id).first()
    if not quiz:
        return {"detail": "Quiz not found"}
    questions = db.query(Question).filter(Question.quiz_id == quiz_id).all()
    score = 0
    max_score = 0
    for q in questions:
        max_score += q.points
        user_answer = answers.get(q.id)
        if user_answer == q.correct_answer:
            score += q.points
    passed = (score / max_score * 100) >= quiz.passing_score if max_score > 0 else False
    
    attempt = QuizAttempt(
        quiz_id=quiz_id,
        user_id=user_id,
        score=score,
        max_score=max_score,
        passed=passed,
        completed_at=datetime.utcnow(),
        answers=str(answers),
    )
    db.add(attempt)
    db.commit()
    db.refresh(attempt)
    return {"attempt_id": attempt.id, "score": score, "max_score": max_score, "passed": passed}

@router.get("/documents/")
async def list_documents(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    docs = db.query(Document).all()
    return docs

@router.get("/progress/me")
async def get_my_progress(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    progress = db.query(Progress).filter(Progress.user_id == user_id).all()
    return progress
