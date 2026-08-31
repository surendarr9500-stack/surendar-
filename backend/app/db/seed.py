from sqlalchemy.orm import Session
from ..db.session import SessionLocal
from ..models.user import User
from ..models.component import Component, ComponentFault, DigitalTwinModel
from ..models.course import Course, Module, Lesson, Quiz, Question, Document
from ..core.security import get_password_hash
from datetime import datetime, timedelta
import uuid

def seed_data():
    db = SessionLocal()
    try:
        # Check if already seeded
        if db.query(User).first():
            print("Database already seeded, skipping")
            return
        
        print("Seeding database...")
        
        # Users
        users = [
            User(
                id=str(uuid.uuid4()),
                username="admin",
                email="admin@moes.gov.in",
                password_hash=get_password_hash("Admin@123"),
                role="administrator",
                display_name="System Administrator",
                is_active=True,
            ),
            User(
                id=str(uuid.uuid4()),
                username="field_engineer",
                email="field@moes.gov.in",
                password_hash=get_password_hash("Field@123"),
                role="field_engineer",
                display_name="Field Engineer",
                is_active=True,
            ),
            User(
                id=str(uuid.uuid4()),
                username="technician",
                email="tech@moes.gov.in",
                password_hash=get_password_hash("Tech@123"),
                role="technician",
                display_name="Technician",
                is_active=True,
            ),
            User(
                id=str(uuid.uuid4()),
                username="training_officer",
                email="training@moes.gov.in",
                password_hash=get_password_hash("Training@123"),
                role="training_officer",
                display_name="Training Officer",
                is_active=True,
            ),
            User(
                id=str(uuid.uuid4()),
                username="supervisor",
                email="supervisor@moes.gov.in",
                password_hash=get_password_hash("Supervisor@123"),
                role="supervisor",
                display_name="Supervisor",
                is_active=True,
            ),
        ]
        for user in users:
            db.add(user)
        db.commit()
        
        # Components
        components = [
            Component(
                id="SONAR-001",
                name="Sonar Transducer Array",
                category="Sonar",
                description="High-frequency sonar transducer array for seabed mapping and underwater object detection. Critical for oceanographic surveys.",
                manufacturer="Kongsberg Maritime",
                model="EM-2040",
                mesh_id="Mesh_042",
                x=10.5, y=2.3, z=1.8,
                status="NORMAL",
                installation_location="Bow Hull Mount",
                possible_faults=["Casing fracture", "Abnormal vibration", "Transducer failure", "Calibration drift", "Water ingress"],
                maintenance_procedures=["Inspect casing for fractures", "Check vibration isolation mounts", "Run self-test diagnostic", "Calibrate transducer array", "Check sealing"],
                training_references=["Sonar Operations Course", "Transducer Maintenance"],
                documentation_references=["SONAR-001-Manual-v2.1", "SONAR-Troubleshooting-Guide"],
                last_inspection=datetime.utcnow() - timedelta(days=30),
                next_maintenance=datetime.utcnow() + timedelta(days=60),
                version=1,
            ),
            Component(
                id="TELEM-001",
                name="Telemetry Transceiver Mast",
                category="Telemetry",
                description="High-gain telemetry mast for satellite and RF communication with research vessel and shore station.",
                manufacturer="Cobham SATCOM",
                model="SAILOR 900",
                mesh_id="Mesh_109",
                x=5.2, y=8.1, z=12.5,
                status="NORMAL",
                installation_location="Main Mast Top",
                possible_faults=["Signal loss", "Mast corrosion", "Transceiver failure", "Antenna misalignment", "Cable damage"],
                maintenance_procedures=["Check signal strength", "Inspect mast for corrosion", "Test transceiver", "Verify antenna alignment", "Check cable integrity"],
                training_references=["Telemetry Systems Course"],
                documentation_references=["TELEM-001-Manual"],
                last_inspection=datetime.utcnow() - timedelta(days=15),
                next_maintenance=datetime.utcnow() + timedelta(days=75),
                version=1,
            ),
            Component(
                id="ARGO-001",
                name="Autonomous Argo Profiling Float",
                category="Argo",
                description="Autonomous profiling float for measuring temperature, salinity, and pressure in deep ocean.",
                manufacturer="Teledyne Webb",
                model="APEX",
                mesh_id="Mesh_210",
                x=-3.5, y=1.2, z=0.5,
                status="NORMAL",
                installation_location="Aft Deck Storage",
                possible_faults=["Buoyancy failure", "Sensor drift", "Battery low", "Communication failure", "Pressure housing leak"],
                maintenance_procedures=["Test buoyancy engine", "Calibrate CTD sensors", "Check battery voltage", "Test Iridium communication", "Inspect pressure housing"],
                training_references=["Argo Float Maintenance"],
                documentation_references=["ARGO-001-Manual"],
                last_inspection=datetime.utcnow() - timedelta(days=10),
                next_maintenance=datetime.utcnow() + timedelta(days=90),
                version=1,
            ),
            Component(
                id="ECHO-001",
                name="Multi-beam Echo Sounder",
                category="Echo Sounder",
                description="Multi-beam echo sounder for high-resolution bathymetric mapping.",
                manufacturer="Kongsberg",
                model="EM-304",
                mesh_id="Mesh_315",
                x=8.0, y=0.5, z=-2.0,
                status="NORMAL",
                installation_location="Hull Mount Midship",
                possible_faults=["Echo loss", "Calibration error", "Beam failure", "Motion sensor error", "Sound velocity error"],
                maintenance_procedures=["Check echo returns", "Run calibration", "Test beamforming", "Verify motion reference unit", "Update sound velocity profile"],
                training_references=["Echo Sounder Operations"],
                documentation_references=["ECHO-001-Manual"],
                last_inspection=datetime.utcnow() - timedelta(days=20),
                next_maintenance=datetime.utcnow() + timedelta(days=50),
                version=1,
            ),
            Component(
                id="WINCH-001",
                name="Hydraulic Deep-Sea Winch",
                category="Winch",
                description="Hydraulic winch for deploying and recovering deep-sea instrumentation and sampling equipment.",
                manufacturer="Dynacon",
                model="D-2000",
                mesh_id="Mesh_410",
                x=-8.5, y=2.0, z=3.0,
                status="NORMAL",
                installation_location="Aft Deck Port Side",
                possible_faults=["Hydraulic leak", "Cable tension high", "Motor overheat", "Brake failure", "Spooling issue"],
                maintenance_procedures=["Check hydraulic fluid level", "Inspect cable for wear", "Monitor motor temperature", "Test brake system", "Check spooling mechanism"],
                training_references=["Winch Operations and Safety"],
                documentation_references=["WINCH-001-Manual", "Winch-Safety-Procedures"],
                last_inspection=datetime.utcnow() - timedelta(days=5),
                next_maintenance=datetime.utcnow() + timedelta(days=30),
                version=1,
            ),
        ]
        for comp in components:
            db.add(comp)
        db.commit()
        
        # Component Faults
        faults = [
            ComponentFault(id=str(uuid.uuid4()), component_id="SONAR-001", fault_code="SONAR-F001", fault_name="Casing fracture", description="Physical fracture in transducer casing", severity="HIGH", keywords=["fracture", "crack", "casing", "housing break"]),
            ComponentFault(id=str(uuid.uuid4()), component_id="SONAR-001", fault_code="SONAR-F002", fault_name="Abnormal vibration", description="Abnormal vibration detected in transducer array", severity="HIGH", keywords=["vibration", "shaking", "abnormal", "resonance"]),
            ComponentFault(id=str(uuid.uuid4()), component_id="TELEM-001", fault_code="TELEM-F001", fault_name="Signal loss", description="Complete loss of telemetry signal", severity="CRITICAL", keywords=["signal loss", "no signal", "communication failure"]),
            ComponentFault(id=str(uuid.uuid4()), component_id="ARGO-001", fault_code="ARGO-F001", fault_name="Buoyancy failure", description="Float unable to maintain buoyancy", severity="HIGH", keywords=["buoyancy", "float", "sinking"]),
            ComponentFault(id=str(uuid.uuid4()), component_id="ECHO-001", fault_code="ECHO-F001", fault_name="Echo loss", description="Loss of echo returns", severity="MEDIUM", keywords=["echo loss", "no echo", "bathymetry failure"]),
            ComponentFault(id=str(uuid.uuid4()), component_id="WINCH-001", fault_code="WINCH-F001", fault_name="Hydraulic leak", description="Hydraulic fluid leak detected", severity="CRITICAL", keywords=["hydraulic leak", "fluid leak", "oil leak"]),
        ]
        for fault in faults:
            db.add(fault)
        db.commit()
        
        # Digital Twin Models
        models = [
            DigitalTwinModel(id=str(uuid.uuid4()), component_id="SONAR-001", mesh_id="Mesh_042", file_path="/models/sonar.glb", file_url="/api/v1/digital-twin/models/Mesh_042/download", version=1, checksum="abc123", file_size=5242880),
            DigitalTwinModel(id=str(uuid.uuid4()), component_id="TELEM-001", mesh_id="Mesh_109", file_path="/models/telemetry.glb", file_url="/api/v1/digital-twin/models/Mesh_109/download", version=1, checksum="def456", file_size=3145728),
            DigitalTwinModel(id=str(uuid.uuid4()), component_id="ARGO-001", mesh_id="Mesh_210", file_path="/models/argo.glb", file_url="/api/v1/digital-twin/models/Mesh_210/download", version=1, checksum="ghi789", file_size=2097152),
            DigitalTwinModel(id=str(uuid.uuid4()), component_id="ECHO-001", mesh_id="Mesh_315", file_path="/models/echo.glb", file_url="/api/v1/digital-twin/models/Mesh_315/download", version=1, checksum="jkl012", file_size=4194304),
            DigitalTwinModel(id=str(uuid.uuid4()), component_id="WINCH-001", mesh_id="Mesh_410", file_path="/models/winch.glb", file_url="/api/v1/digital-twin/models/Mesh_410/download", version=1, checksum="mno345", file_size=6291456),
        ]
        for m in models:
            db.add(m)
        db.commit()
        
        # Courses
        course1 = Course(id=str(uuid.uuid4()), title="Sonar Operations and Maintenance", description="Comprehensive training on sonar transducer operations, troubleshooting, and maintenance for oceanographic surveys.", category="Sonar", difficulty="intermediate", duration_minutes=240, version=1, is_published=True, offline_available=True)
        db.add(course1)
        db.commit()
        
        module1 = Module(id=str(uuid.uuid4()), course_id=course1.id, title="Sonar Fundamentals", order_index=0, description="Introduction to sonar principles and transducer array")
        module2 = Module(id=str(uuid.uuid4()), course_id=course1.id, title="Troubleshooting", order_index=1, description="Common faults and diagnostic procedures")
        db.add_all([module1, module2])
        db.commit()
        
        lesson1 = Lesson(id=str(uuid.uuid4()), module_id=module1.id, title="Sonar Transducer Overview", type="video", order_index=0, duration_minutes=30, content_url="/media/sonar_overview.mp4", version=1)
        lesson2 = Lesson(id=str(uuid.uuid4()), module_id=module1.id, title="Installation and Calibration", type="document", order_index=1, duration_minutes=45, content_url="/docs/sonar_install.pdf", version=1)
        lesson3 = Lesson(id=str(uuid.uuid4()), module_id=module2.id, title="Vibration and Fracture Diagnostics", type="video", order_index=0, duration_minutes=60, content_url="/media/sonar_diagnostics.mp4", version=1)
        lesson4 = Lesson(id=str(uuid.uuid4()), module_id=module2.id, title="Quiz: Sonar Troubleshooting", type="quiz", order_index=1, duration_minutes=20, version=1)
        db.add_all([lesson1, lesson2, lesson3, lesson4])
        db.commit()
        
        # Quiz
        quiz = Quiz(id=str(uuid.uuid4()), course_id=course1.id, lesson_id=lesson4.id, title="Sonar Troubleshooting Assessment", description="Test your knowledge of sonar fault diagnosis", passing_score=70, time_limit_minutes=20, version=1, is_published=True)
        db.add(quiz)
        db.commit()
        
        questions = [
            Question(id=str(uuid.uuid4()), quiz_id=quiz.id, question_text="What is the first step when casing fracture is detected?", type="multiple_choice", options='["Power down system", "Continue operation", "Ignore and monitor", "Increase power"]', correct_answer="Power down system", explanation="Safety first: power down to prevent water ingress", order_index=0, points=1),
            Question(id=str(uuid.uuid4()), quiz_id=quiz.id, question_text="Abnormal vibration in sonar transducer is classified as HIGH severity", type="true_false", options='["True", "False"]', correct_answer="True", explanation="Vibration indicates mechanical failure risk", order_index=1, points=1),
            Question(id=str(uuid.uuid4()), quiz_id=quiz.id, question_text="Which mesh ID corresponds to Sonar Transducer Array?", type="multiple_choice", options='["Mesh_042", "Mesh_109", "Mesh_210", "Mesh_315"]', correct_answer="Mesh_042", explanation="SONAR-001 maps to Mesh_042", order_index=2, points=1),
        ]
        for q in questions:
            db.add(q)
        db.commit()
        
        # Documents
        docs = [
            Document(id=str(uuid.uuid4()), title="SONAR-001 Technical Manual v2.1", version=1, category="Manual", component_id="SONAR-001", language="en", file_url="/docs/sonar_manual_v2.1.pdf", offline_available=True, fts_content="Sonar transducer array technical manual including installation, operation, troubleshooting, casing fracture, vibration analysis"),
            Document(id=str(uuid.uuid4()), title="Telemetry Systems Operations Guide", version=1, category="Manual", component_id="TELEM-001", language="en", file_url="/docs/telemetry_guide.pdf", offline_available=True, fts_content="Telemetry transceiver mast operations, signal loss troubleshooting, mast corrosion prevention"),
            Document(id=str(uuid.uuid4()), title="Argo Float Maintenance Procedures", version=1, category="Maintenance", component_id="ARGO-001", language="en", file_url="/docs/argo_maintenance.pdf", offline_available=True, fts_content="Argo profiling float maintenance, buoyancy testing, sensor calibration, battery replacement"),
        ]
        for doc in docs:
            db.add(doc)
        db.commit()
        
        print("Database seeded successfully")
        
    except Exception as e:
        print(f"Error seeding database: {e}")
        db.rollback()
    finally:
        db.close()
