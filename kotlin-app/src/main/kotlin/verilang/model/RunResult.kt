package verilang.model

import kotlinx.serialization.Serializable

/**
 * Resultado que devuelve RunnerJson.rsc de VeriLang en formato JSON.
 *
 * Campos estándar:
 *   - success        → true si todo corrió sin errores
 *   - parseOk        → true si el parsing fue exitoso
 *   - typeCheckOk    → true si el type checking pasó
 *   - semanticOk     → true si las reglas semánticas pasaron
 *
 * Campos específicos de VeriLang:
 *   - module         → nombre del módulo (defmodule X)
 *   - moduleImports  → lista de módulos importados (using X)
 *   - moduleComponents → lista de componentes del módulo (operadores, espacios, reglas, etc.)
 *   - typeErrors     → mensajes de error de TypePal
 *   - error          → excepción o error general de Rascal
 *   - resumen        → resumen textual del AST
 */
@Serializable
data class RunResult(
    val success: Boolean = false,
    val parseOk: Boolean = false,
    val typeCheckOk: Boolean = false,
    val semanticOk: Boolean = false,
    val module: String = "",
    val moduleImports: List<String> = emptyList(),
    val moduleComponents: List<String> = emptyList(),
    val typeErrors: List<String> = emptyList(),
    val semanticErrors: List<String> = emptyList(),
    val output: List<String> = emptyList(),
    val error: String = "",
    val codigoFormateado: String = "",
    val resumen: String = ""
)
