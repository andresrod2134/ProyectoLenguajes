package verilang.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import verilang.model.RunResult
import verilang.service.LangService
import java.io.File
import javax.swing.JFileChooser
import javax.swing.filechooser.FileNameExtensionFilter

@Composable
fun MainWindow() {
    val service = remember { LangService() }
    val scope = rememberCoroutineScope()

    var filePath by remember { mutableStateOf("") }
    var result by remember { mutableStateOf<RunResult?>(null) }
    var running by remember { mutableStateOf(false) }

    val bg          = Color(0xFF0D1117)
    val navBar      = Color(0xFF161B22)
    val surface     = Color(0xFF1C2333)
    val surfaceAlt  = Color(0xFF21262D)
    val border      = Color(0xFF30363D)
    val accent      = Color(0xFF58A6FF)
    val green       = Color(0xFF3FB950)
    val red         = Color(0xFFF85149)
    val yellow      = Color(0xFFD29922)
    val purple      = Color(0xFFBC8CFF)
    val teal        = Color(0xFF39D353)
    val textPrimary = Color(0xFFE6EDF3)
    val textMuted   = Color(0xFF8B949E)

    Column(modifier = Modifier.fillMaxSize().background(bg)) {

        // ── Barra superior ─────────────────────────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(navBar)
                .border(width = 1.dp, color = border, shape = RoundedCornerShape(0.dp))
                .padding(horizontal = 24.dp, vertical = 14.dp)
        ) {
            Column {
                Row(verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    Box(
                        modifier = Modifier
                            .background(accent.copy(alpha = 0.15f), RoundedCornerShape(4.dp))
                            .padding(horizontal = 8.dp, vertical = 3.dp)
                    ) {
                        Text("VL", color = accent, fontSize = 11.sp,
                            fontWeight = FontWeight.Bold, fontFamily = FontFamily.Monospace)
                    }
                    Text("VeriLang Runner", color = textPrimary,
                        fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                }
                Spacer(Modifier.height(2.dp))
                Text("Elementos Esenciales de Lenguajes de Programacion · ISIS-2111 · Uniandes",
                    color = textMuted, fontSize = 11.sp, fontFamily = FontFamily.Monospace)
            }
        }

        // ── Contenido ──────────────────────────────────────────────────────
        Column(
            modifier = Modifier.fillMaxSize().padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Panel archivo
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(surface, RoundedCornerShape(8.dp))
                    .border(1.dp, border, RoundedCornerShape(8.dp))
                    .padding(16.dp)
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("ARCHIVO FUENTE", color = textMuted, fontSize = 10.sp,
                        fontWeight = FontWeight.Bold, fontFamily = FontFamily.Monospace,
                        letterSpacing = 1.5.sp)
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        OutlinedTextField(
                            value = filePath,
                            onValueChange = { filePath = it },
                            placeholder = { Text("ruta/al/archivo.vl",
                                color = textMuted, fontFamily = FontFamily.Monospace, fontSize = 13.sp) },
                            modifier = Modifier.weight(1f),
                            singleLine = true,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedTextColor = textPrimary,
                                unfocusedTextColor = textPrimary,
                                focusedBorderColor = accent,
                                unfocusedBorderColor = border,
                                focusedContainerColor = surfaceAlt,
                                unfocusedContainerColor = surfaceAlt
                            )
                        )
                        Button(
                            onClick = {
                                val chooser = JFileChooser().apply {
                                    fileFilter = FileNameExtensionFilter("VeriLang (*.vl)", "vl")
                                    currentDirectory = File(System.getProperty("user.home"))
                                }
                                if (chooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION)
                                    filePath = chooser.selectedFile.absolutePath
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = surfaceAlt),
                            border = ButtonDefaults.outlinedButtonBorder,
                            shape = RoundedCornerShape(6.dp)
                        ) { Text("Buscar", color = textPrimary, fontSize = 13.sp) }

                        Button(
                            onClick = {
                                scope.launch {
                                    running = true
                                    result = service.run(filePath.trim())
                                    running = false
                                }
                            },
                            enabled = filePath.isNotBlank() && !running,
                            colors = ButtonDefaults.buttonColors(containerColor = accent),
                            shape = RoundedCornerShape(6.dp)
                        ) {
                            if (running)
                                CircularProgressIndicator(modifier = Modifier.size(16.dp),
                                    color = bg, strokeWidth = 2.dp)
                            else
                                Text("Ejecutar", color = bg,
                                    fontWeight = FontWeight.SemiBold, fontSize = 13.sp)
                        }
                    }
                }
            }

            // Panel resultados
            result?.let { r ->
                Column(
                    modifier = Modifier.fillMaxWidth().verticalScroll(rememberScrollState()),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    // Estado + módulo
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(surface, RoundedCornerShape(8.dp))
                            .border(1.dp, border, RoundedCornerShape(8.dp))
                            .padding(16.dp)
                    ) {
                        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                            Text("RESULTADO", color = textMuted, fontSize = 10.sp,
                                fontWeight = FontWeight.Bold, fontFamily = FontFamily.Monospace,
                                letterSpacing = 1.5.sp)
                            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                StatusChip("Parser",    r.parseOk,     green, red)
                                StatusChip("TypeCheck", r.typeCheckOk, green, yellow)
                                StatusChip("Semantica", r.semanticOk,  green, red)
                            }
                            if (r.module.isNotBlank()) {
                                Row(horizontalArrangement = Arrangement.spacedBy(8.dp),
                                    verticalAlignment = Alignment.CenterVertically) {
                                    Text("modulo", color = textMuted,
                                        fontSize = 12.sp, fontFamily = FontFamily.Monospace)
                                    Text(r.module, color = accent,
                                        fontSize = 13.sp, fontFamily = FontFamily.Monospace,
                                        fontWeight = FontWeight.Bold)
                                }
                            }
                        }
                    }

                    // Imports
                    if (r.moduleImports.isNotEmpty()) {
                        IdeSection(
                            label = "MODULOS IMPORTADOS",
                            content = r.moduleImports.joinToString("\n") { "  using $it" },
                            color = teal, bg = surface, borderColor = border)
                    }

                    // Componentes
                    if (r.moduleComponents.isNotEmpty()) {
                        IdeSection(
                            label = "COMPONENTES DEL MODULO  (${r.moduleComponents.size})",
                            content = r.moduleComponents.joinToString("\n") { "  $it" },
                            color = purple, bg = surface, borderColor = border)
                    }

                    // Error general — solo si hay error
                    if (r.error.isNotBlank()) {
                        IdeSection(label = "ERROR", content = r.error,
                            color = red, bg = surface, borderColor = border)
                    }

                    // Errores de tipos — solo si hay errores
                    if (r.typeErrors.isNotEmpty()) {
                        IdeSection(
                            label = "ERRORES DE TIPOS  (${r.typeErrors.size})",
                            content = r.typeErrors.joinToString("\n") { "  $it" },
                            color = yellow, bg = surface, borderColor = border)
                    }

                    // Errores semanticos — solo si hay errores
                    if (r.semanticErrors.isNotEmpty()) {
                        IdeSection(
                            label = "ERRORES SEMANTICOS  (${r.semanticErrors.size})",
                            content = r.semanticErrors.joinToString("\n") { "  $it" },
                            color = red, bg = surface, borderColor = border)
                    }
                }
            }
        }
    }
}

@Composable
private fun StatusChip(label: String, ok: Boolean, okColor: Color, failColor: Color) {
    val color = if (ok) okColor else failColor
    val icon  = if (ok) "✓" else "✗"
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(4.dp))
            .background(color.copy(alpha = 0.15f))
            .border(1.dp, color.copy(alpha = 0.4f), RoundedCornerShape(4.dp))
            .padding(horizontal = 12.dp, vertical = 5.dp)
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(5.dp),
            verticalAlignment = Alignment.CenterVertically) {
            Text(icon, color = color, fontSize = 11.sp, fontWeight = FontWeight.Bold)
            Text(label, color = color, fontSize = 12.sp, fontFamily = FontFamily.Monospace)
        }
    }
}

@Composable
private fun IdeSection(label: String, content: String, color: Color, bg: Color, borderColor: Color) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(bg, RoundedCornerShape(8.dp))
            .border(1.dp, borderColor, RoundedCornerShape(8.dp))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(label, color = color, fontSize = 10.sp,
            fontWeight = FontWeight.Bold, fontFamily = FontFamily.Monospace,
            letterSpacing = 1.5.sp)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color(0xFF0D1117), RoundedCornerShape(6.dp))
                .padding(12.dp)
                .heightIn(max = 200.dp)
                .verticalScroll(rememberScrollState())
        ) {
            Text(content, color = Color(0xFFE6EDF3),
                fontFamily = FontFamily.Monospace, fontSize = 12.sp,
                lineHeight = 18.sp)
        }
    }
}