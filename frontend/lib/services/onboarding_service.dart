import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../config/app_theme.dart';

class OnboardingService {
  static void showSpotlight({
    required BuildContext context,
    required List<TargetFocus> targets,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SALTAR",
      paddingFocus: 10,
      opacityShadow: 0.95,
      onFinish: () => print("Onboarding finished"),
      onClickTarget: (target) => print("Target clicked: ${target.identify}"),
      onSkip: () => true,
    ).show(context: context);
  }

  static List<TargetFocus> getStudentTargets(
    GlobalKey headerKey,
    GlobalKey statsKey,
    GlobalKey coursesKey,
  ) {
    return [
      TargetFocus(
        identify: "header",
        keyTarget: headerKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildContent(
              "¡Bienvenido a EnfoEduca!",
              "Aquí puedes ver tu nivel actual y los puntos que has ganado gamificando tu aprendizaje.",
              context,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "stats",
        keyTarget: statsKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildContent(
              "Tus Estadísticas",
              "Lleva el control de tus cursos inscritos y tareas pendientes de un vistazo.",
              context,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "courses",
        keyTarget: coursesKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildContent(
              "Mis Cursos",
              "Accede rápidamente a tus materias favoritas y revisa el material de clase.",
              context,
            ),
          ),
        ],
      ),
    ];
  }

  static List<TargetFocus> getTeacherTargets(
    GlobalKey statsKey,
    GlobalKey actionsKey,
  ) {
    return [
      TargetFocus(
        identify: "stats",
        keyTarget: statsKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildContent(
              "Gestión de Alumnos",
              "Monitorea el total de alumnos y cuántas tareas tienes pendientes por calificar.",
              context,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "actions",
        keyTarget: actionsKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildContent(
              "Acciones Rápidas",
              "Crea tareas, toma asistencia o envía anuncios a todo el salón en segundos.",
              context,
            ),
          ),
        ],
      ),
    ];
  }

  static List<TargetFocus> getAdminTargets(
    GlobalKey statsKey,
    GlobalKey actionsKey,
  ) {
    return [
      TargetFocus(
        identify: "stats",
        keyTarget: statsKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildContent(
              "Panel de Control",
              "Visualiza el estado global de la plataforma: total de usuarios, cursos activos y reportes generados.",
              context,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "actions",
        keyTarget: actionsKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildContent(
              "Gestión de Cuentas",
              "Como administrador, puedes asignar nuevas cuentas y gestionar los roles de todo el personal.",
              context,
            ),
          ),
        ],
      ),
    ];
  }

  static List<TargetFocus> getParentTargets(
    GlobalKey childrenKey,
    GlobalKey notificationsKey,
  ) {
    return [
      TargetFocus(
        identify: "children",
        keyTarget: childrenKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildContent(
              "Progreso de tus Hijos",
              "Aquí puedes ver el rendimiento académico, puntos y nivel de cada uno de tus hijos inscritos.",
              context,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "notifications",
        keyTarget: notificationsKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildContent(
              "Notificaciones en Tiempo Real",
              "Entérate al instante cuando un profesor califique una tarea o publique un anuncio importante.",
              context,
            ),
          ),
        ],
      ),
    ];
  }

  static Widget _buildContent(String title, String desc, BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "TUTORIAL",
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {}, // Handled by the package to go to next step
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continuar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
