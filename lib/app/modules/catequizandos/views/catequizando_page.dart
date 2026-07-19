import 'dart:io';
import 'dart:typed_data';
import '../../../core/utils/download_helper.dart'
    if (dart.library.html) '../../../core/utils/download_helper_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:plataforma_pnsa_catequese/app/core/services/google_drive_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../models/catequizando_model.dart';
import '../models/documento_anexado.dart';
import '../viewmodels/catequizando_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import '../../../core/utils/certificate_generator.dart';
import 'catequizando_table.dart';
import '../widgets/editar_catequizando_bottom_sheet.dart';
import '../widgets/frequencia_bottom_sheet.dart';
import '../../encontros/viewmodels/encontros_viewmodel.dart';
import '../../configuracao/views/configuracao_drive_page.dart';

void showHistoricoDialog(BuildContext context, Catequizando catequizando, MatriculaViewModel matriculaVm, List<TurmaModel> turmas) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final historico = matriculaVm.getHistoricoComTurma(catequizando.id, turmas);

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.history_rounded, color: colorScheme.onPrimary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Histórico de Matrículas', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                        Text(catequizando.nome, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (historico.isEmpty)
              const Expanded(
                child: Center(child: Text('Nenhum histórico encontrado')),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: historico.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = historico[i];
                    final m = item.matricula;
                    final statusColor = m.status == 'Ativa'
                        ? colorScheme.primary
                        : m.status == 'Concluída'
                            ? colorScheme.tertiary
                            : colorScheme.error;

                    return Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                m.status == 'Ativa' ? Icons.menu_book_rounded : Icons.check_circle_outline_rounded,
                                color: statusColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.turmaNome ?? 'Turma removida',
                                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          m.status,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 13, color: colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM/yyyy').format(m.dataMatricula),
                                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                      ),
                                      if (m.dataConclusao != null) ...[
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 13, color: colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('MMM/yyyy').format(m.dataConclusao!),
                                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (m.observacoes != null && m.observacoes!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(m.observacoes!, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showDocumentosDialog(BuildContext context, CatequizandoViewModel vm,
    {required Catequizando catequizando}) {
  final theme = Theme.of(context);
  final driveService = Get.find<GoogleDriveService>();

  if (!driveService.isReady) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Acesso aos arquivos'),
        content: const Text('Conecte a conta sistemapnsacatequese@gmail.com nas Config. Drive para acessar os arquivos.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Fechar')),
          FilledButton(onPressed: () { Navigator.of(ctx).pop(); Get.to(() => const ConfiguracaoDrivePage()); }, child: const Text('Config. Drive')),
        ],
      ),
    );
    return;
  }

  final docs = RxList<DocumentoAnexado>.from(catequizando.documentosAnexados);
  final uploading = false.obs;
  String? pastaId = catequizando.driveFolderId;

  Future<void> baixarArquivo(DocumentoAnexado doc) async {
    try {
      final bytes = await driveService.downloadFile(doc.driveFileId!);
      downloadBytes(bytes, '${doc.nome}.${doc.extensao}');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao baixar arquivo: $e');
    }
  }

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.colorScheme.surface,
        ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.folder_copy_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Documentos', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                        Text(catequizando.nome, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (!driveService.isReady) return const SizedBox.shrink();
                return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: uploading.value
                      ? null
                      : () async {
                          const maxBytes = 2097152;
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'doc', 'docx'],
                            allowMultiple: true,
                          );
                          if (result == null || result.files.isEmpty) return;

                          final extOk = {'pdf', 'doc', 'docx'};
                          final validFiles = result.files.where((f) {
                            final ext = (f.extension ?? '').toLowerCase();
                            if (!extOk.contains(ext)) {
                              Get.snackbar('Formato inválido', '${f.name} não é PDF ou Word.', snackPosition: SnackPosition.BOTTOM);
                              return false;
                            }
                            if (f.size > maxBytes) {
                              Get.snackbar('Arquivo muito grande', '${f.name} ultrapassa 2 MB.', snackPosition: SnackPosition.BOTTOM);
                              return false;
                            }
                            return true;
                          }).toList();
                          if (validFiles.isEmpty) return;

                          if (!driveService.isReady) {
                            await Get.dialog(AlertDialog(
                              title: const Text('Drive não configurado'),
                              content: const Text('Conecte a conta sistemapnsacatequese@gmail.com em "Config. Drive" para acessar os arquivos.'),
                              actions: [
                                TextButton(onPressed: () => Get.back(), child: const Text('Fechar')),
                                FilledButton(onPressed: () { Get.back(); Get.to(() => const ConfiguracaoDrivePage()); }, child: const Text('Config. Drive')),
                              ],
                            ));
                            return;
                          }

                          uploading.value = true;
                          try {
                            if (pastaId == null) {
                              try {
                                pastaId = await driveService.createFolder(
                                  catequizando.nome,
                                );
                                debugPrint('[Drive] Pasta criada: $pastaId');
                              } catch (e) {
                                debugPrint('[Drive] Erro ao criar pasta: $e');
                                Get.snackbar('Erro', 'Falha ao criar pasta no Drive: $e');
                                return;
                              }
                            }

                            for (final f in validFiles) {
                              try {
                                Uint8List bytes;
                                if (f.bytes != null) {
                                  bytes = f.bytes!;
                                } else if (f.path != null) {
                                  bytes = await File(f.path!).readAsBytes();
                                } else {
                                  debugPrint('[Drive] bytes e path nulos para ${f.name}');
                                  continue;
                                }
                                debugPrint('[Drive] Enviando: ${f.name}, tamanho: ${bytes.length}, pasta: $pastaId');

                                DocumentoDrive driveFile;
                                try {
                                  driveFile = await driveService.uploadFile(
                                    bytes: bytes,
                                    nome: f.name,
                                    parentFolderId: pastaId,
                                  );
                                } catch (e) {
                                  if (e.toString().contains('404') && e.toString().contains('File not found')) {
                                    debugPrint('[Drive] Pasta não encontrada, recriando...');
                                    pastaId = await driveService.createFolder(catequizando.nome);
                                    debugPrint('[Drive] Nova pasta criada: $pastaId');
                                    driveFile = await driveService.uploadFile(
                                      bytes: bytes,
                                      nome: f.name,
                                      parentFolderId: pastaId,
                                    );
                                  } else {
                                    rethrow;
                                  }
                                }

                                debugPrint('[Drive] Sucesso: ${f.name} -> ID: ${driveFile.driveFileId}');
                                docs.add(DocumentoAnexado(
                                  nome: f.name,
                                  extensao: f.extension ?? '',
                                  tamanho: f.size,
                                  driveFileId: driveFile.driveFileId,
                                  webViewLink: driveFile.webViewLink,
                                  downloadLink: driveFile.downloadLink,
                                ));
                                vm.updateCatequizando(Catequizando(
                                  id: catequizando.id,
                                  nome: catequizando.nome,
                                  dataNascimento: catequizando.dataNascimento,
                                  sexo: catequizando.sexo,
                                  batizado: catequizando.batizado,
                                  localBatismo: catequizando.localBatismo,
                                  fezPrimeiraEucaristia: catequizando.fezPrimeiraEucaristia,
                                  detalheEucaristia: catequizando.detalheEucaristia,
                                  fezCrisma: catequizando.fezCrisma,
                                  detalheCrisma: catequizando.detalheCrisma,
                                  responsavel: catequizando.responsavel,
                                  parentesco: catequizando.parentesco,
                                  telefone: catequizando.telefone,
                                  cep: catequizando.cep,
                                  endereco: catequizando.endereco,
                                  numero: catequizando.numero,
                                  bairro: catequizando.bairro,
                                  possuiRestricao: catequizando.possuiRestricao,
                                  detalheRestricao: catequizando.detalheRestricao,
                                  aceiteTermos: catequizando.aceiteTermos,
                                  assinaturaResponsavel: catequizando.assinaturaResponsavel,
                                  dataAssinatura: catequizando.dataAssinatura,
                                  documentosAnexados: docs.toList(),
                                  driveFolderId: pastaId ?? catequizando.driveFolderId,
                                ));
                              } catch (e) {
                                debugPrint('[Drive] Erro ao enviar ${f.name}: $e');
                                Get.snackbar(
                                  'Aviso',
                                  'Erro ao enviar ${f.name}: $e',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            }
                          } finally {
                            uploading.value = false;
                          }
                        },
                  icon: Obx(() {
                    if (uploading.value) {
                      return const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return const Icon(Icons.cloud_upload_rounded);
                  }),
                  label: Obx(() => Text(uploading.value ? 'Enviando...' : 'Adicionar documentos (PDF, Word — máx. 2 MB)')),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                );
              }),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (!driveService.isReady) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off_rounded, size: 48, color: theme.colorScheme.error.withOpacity(0.6)),
                            const SizedBox(height: 16),
                            Text(
                              'Conecte a conta sistemapnsacatequese@gmail.com nas Config. Drive para acessar os arquivos.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => Get.to(() => const ConfiguracaoDrivePage()),
                              icon: const Icon(Icons.settings_rounded),
                              label: const Text('Config. Drive'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open_rounded, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                          const SizedBox(height: 8),
                          Text('Nenhum documento anexado', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4))),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final doc = docs[i];
                      final temDrive = doc.driveFileId != null && doc.driveFileId!.isNotEmpty;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            temDrive ? Icons.cloud_done_rounded : Icons.insert_drive_file_rounded,
                            color: temDrive ? Colors.green : theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(doc.descricao, style: const TextStyle(fontSize: 13)),
                        subtitle: temDrive
                            ? Text('No Google Drive', style: TextStyle(fontSize: 11, color: Colors.green.shade600))
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (temDrive)
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 18,
                                  icon: Icon(Icons.download_rounded, color: theme.colorScheme.primary),
                                  onPressed: () => baixarArquivo(doc),
                                  tooltip: 'Baixar arquivo',
                                ),
                              ),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                onPressed: () async {
                                  final confirm = await Get.dialog<bool>(
                                    AlertDialog(
                                      title: const Text('Excluir arquivo'),
                                      content: const Text('Este arquivo será excluído permanentemente do Google Drive. Tem certeza?'),
                                      actions: [
                                        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancelar')),
                                        FilledButton(onPressed: () => Get.back(result: true), child: const Text('Excluir')),
                                      ],
                                    ),
                                  );
                                  if (confirm != true) return;
                                  if (doc.driveFileId != null && doc.driveFileId!.isNotEmpty) {
                                    await driveService.deleteFile(doc.driveFileId!);
                                  }
                                  docs.removeAt(i);
                                  vm.updateCatequizando(Catequizando(
                                    id: catequizando.id,
                                    nome: catequizando.nome,
                                    dataNascimento: catequizando.dataNascimento,
                                    sexo: catequizando.sexo,
                                    batizado: catequizando.batizado,
                                    localBatismo: catequizando.localBatismo,
                                    fezPrimeiraEucaristia: catequizando.fezPrimeiraEucaristia,
                                    detalheEucaristia: catequizando.detalheEucaristia,
                                    fezCrisma: catequizando.fezCrisma,
                                    detalheCrisma: catequizando.detalheCrisma,
                                    responsavel: catequizando.responsavel,
                                    parentesco: catequizando.parentesco,
                                    telefone: catequizando.telefone,
                                    cep: catequizando.cep,
                                    endereco: catequizando.endereco,
                                    numero: catequizando.numero,
                                    bairro: catequizando.bairro,
                                    possuiRestricao: catequizando.possuiRestricao,
                                    detalheRestricao: catequizando.detalheRestricao,
                                    aceiteTermos: catequizando.aceiteTermos,
                                    assinaturaResponsavel: catequizando.assinaturaResponsavel,
                                    dataAssinatura: catequizando.dataAssinatura,
                                    documentosAnexados: docs.toList(),
                                    driveFolderId: pastaId ?? catequizando.driveFolderId,
                                  ));
                                },
                                tooltip: 'Excluir do Drive',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}

void showEditarCatequizandoDialog(BuildContext context, CatequizandoViewModel vm,
    {required Catequizando catequizando, List<TurmaModel> turmas = const []}) {
  showEditarCatequizandoBottomSheet(context, vm, catequizando: catequizando, turmas: turmas);
}

void _showExportDialog(BuildContext context, Catequizando catequizando, MatriculaViewModel matriculaVm, List<TurmaModel> turmas) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final historico = matriculaVm.getHistoricoComTurma(catequizando.id, turmas);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width < 600
              ? MediaQuery.of(context).size.width
              : 400,
          height: double.infinity,
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width < 600 ? 0 : 0,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 40,
                offset: const Offset(-8, 0),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.picture_as_pdf_rounded, color: colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Exportar Dados', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                          Text(catequizando.nome, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  children: [
                ListTile(
                  leading: Icon(Icons.description_outlined, color: colorScheme.primary),
                  title: const Text('Ficha de Cadastro'),
                  subtitle: const Text('Apenas os dados cadastrais'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    CertificateGenerator.generateFicha(catequizando, withHistory: false);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history_rounded, color: colorScheme.tertiary),
                  title: const Text('Histórico de Matrículas'),
                  subtitle: const Text('Apenas o histórico de matrículas'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    CertificateGenerator.generateHistorico(catequizando, historico);
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.archive_rounded, color: colorScheme.secondary),
                  title: const Text('Ficha + Histórico'),
                  subtitle: const Text('Documento completo com ambos'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    CertificateGenerator.generateFicha(catequizando, withHistory: true);
                  },
                ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.swap_horiz_rounded, color: colorScheme.error),
              title: const Text('Ficha de Transferência'),
              subtitle: const Text('Documento completo para transferência'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                Navigator.pop(ctx);
                CertificateGenerator.generateFicha(catequizando, withHistory: true, subtitle: 'FICHA DE TRANSFERÊNCIA');
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.edit_note_rounded, color: colorScheme.primary),
              title: const Text('Ficha e Termo em Branco'),
              subtitle: const Text('Formulário para preenchimento manual'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    CertificateGenerator.generateFichaBranca();
                  },
                ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
  );
}

class CatequizandoPage extends StatelessWidget {
  final CatequizandoViewModel vm;
  final List<TurmaModel> turmas;
  final MatriculaViewModel matriculaVm;
  final EncontrosViewModel encontrosVm;
  const CatequizandoPage({
    super.key,
    required this.vm,
    this.turmas = const [],
    required this.matriculaVm,
    required this.encontrosVm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, hPad),
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => TextField(
                  onChanged: vm.setSearch,
                  decoration: AppTheme.searchInputDecoration(
                    theme.colorScheme,
                    hintText: 'Buscar catequizando por nome, turma ou responsável...',
                    suffixIcon: vm.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: theme.colorScheme.onSurfaceVariant),
                            onPressed: () => vm.setSearch(''),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filtros Rápidos (Chips)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Obx(() {
            final cs = theme.colorScheme;
            final currentStatus = vm.filterStatus.value;
            final currentSacra = vm.filterSacramento.value;

            return Row(
              children: [
                // Grupo 1: Status
                _buildFilterChip(
                  label: 'Todos',
                  isSelected: currentStatus == 'Todos',
                  onSelected: (_) {
                    vm.filterStatus.value = 'Todos';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: cs.primary,
                ),
                _buildFilterChip(
                  label: 'Em Andamento',
                  isSelected: currentStatus == 'Em Andamento',
                  onSelected: (_) {
                    vm.filterStatus.value = 'Em Andamento';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: Colors.blue.shade700,
                ),
                _buildFilterChip(
                  label: 'Formado',
                  isSelected: currentStatus == 'Formado',
                  onSelected: (_) {
                    vm.filterStatus.value = 'Formado';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: Colors.green.shade700,
                ),
                _buildFilterChip(
                  label: 'Desistente',
                  isSelected: currentStatus == 'Desistente',
                  onSelected: (_) {
                    vm.filterStatus.value = 'Desistente';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: Colors.red.shade700,
                ),
                _buildFilterChip(
                  label: 'Inativo',
                  isSelected: currentStatus == 'Inativo',
                  onSelected: (_) {
                    vm.filterStatus.value = 'Inativo';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: Colors.grey.shade600,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(height: 20, child: VerticalDivider(width: 1, thickness: 1)),
                ),

                // Grupo 2: Sacramentos
                _buildFilterChip(
                  label: 'Sem Restrição',
                  isSelected: currentSacra == 'Todos',
                  onSelected: (_) {
                    vm.filterSacramento.value = 'Todos';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: cs.secondary,
                ),
                _buildFilterChip(
                  label: 'Pendente Batismo',
                  isSelected: currentSacra == 'Pendente Batismo',
                  onSelected: (_) {
                    vm.filterSacramento.value = 'Pendente Batismo';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: Colors.deepPurple.shade600,
                ),
                _buildFilterChip(
                  label: 'Pendente 1ª Eucaristia',
                  isSelected: currentSacra == 'Pendente Eucaristia',
                  onSelected: (_) {
                    vm.filterSacramento.value = 'Pendente Eucaristia';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: Colors.teal.shade700,
                ),
                _buildFilterChip(
                  label: 'Pendente Crisma',
                  isSelected: currentSacra == 'Pendente Crisma',
                  onSelected: (_) {
                    vm.filterSacramento.value = 'Pendente Crisma';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: Colors.indigo.shade700,
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final paginated = vm.paginatedCatequizandos;
          final total = vm.totalPages;
          if (vm.catequizandos.isEmpty) {
            return _buildEmptyState(
              theme: theme,
              icon: Icons.people_outline_rounded,
              title: 'Nenhum catequizando cadastrado',
              subtitle: 'Clique no botão "+" para adicionar o primeiro catequizando.',
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    if (paginated.isEmpty)
                      _buildEmptyState(
                        theme: theme,
                        icon: Icons.search_off_rounded,
                        title: 'Nenhum resultado encontrado',
                        subtitle: 'Tente ajustar os filtros ou o termo de busca.',
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: paginated.length,
                        itemBuilder: (_, i) {
                          final a = paginated[i];
                          return CatequizandoCard(
                            aluno: a,
                            theme: theme,
                            turmas: turmas,
                            matriculaVm: matriculaVm,
                            onHistorico: () => showHistoricoDialog(
                                context, a, matriculaVm, turmas),
                            onEdit: () => showEditarCatequizandoDialog(
                                context, vm, catequizando: a, turmas: turmas),
                            onDelete: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Confirmar Exclusão'),
                                  content: Text('Deseja excluir "${a.nome}"?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Cancelar')),
                                    FilledButton(
                                      onPressed: () {
                                        vm.removeCatequizando(a.id);
                                        Get.back();
                                      },
                                      style: FilledButton.styleFrom(
                                          backgroundColor:
                                              theme.colorScheme.error),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDocumentos: () => showDocumentosDialog(
                                context, vm, catequizando: a),
                            onFrequencia: () => showFrequenciaBottomSheet(
                                context, aluno: a, encontrosVm: encontrosVm, matriculaVm: matriculaVm, turmas: turmas),
                            onExportar: () => _showExportDialog(context, a, matriculaVm, turmas),
                          );
                        },
                      ),
                    if (total > 1) CatequizandoPagination(vm: vm, theme: theme),
                  ],
                );
              }
              return Column(
                children: [
                  if (paginated.isEmpty)
                    _buildEmptyState(
                      theme: theme,
                      icon: Icons.search_off_rounded,
                      title: 'Nenhum resultado encontrado',
                      subtitle: 'Tente ajustar os filtros ou o termo de busca.',
                    )
                  else
                    CatequizandoTable(
                      alunos: paginated,
                      theme: theme,
                      vm: vm,
                      turmas: turmas,
                      matriculaVm: matriculaVm,
                      onHistorico: (a) => showHistoricoDialog(
                          context, a, matriculaVm, turmas),
                      onEdit: (a) => showEditarCatequizandoDialog(
                          context, vm, catequizando: a, turmas: turmas),
                      onDelete: (a) {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Confirmar Exclusão'),
                            content: Text('Deseja excluir "${a.nome}"?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancelar')),
                              FilledButton(
                                onPressed: () {
                                  vm.removeCatequizando(a.id);
                                  Get.back();
                                },
                                style: FilledButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.error),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDocumentos: (a) => showDocumentosDialog(
                          context, vm, catequizando: a),
                      onFrequencia: (a) => showFrequenciaBottomSheet(
                          context, aluno: a, encontrosVm: encontrosVm, matriculaVm: matriculaVm, turmas: turmas),
                      onExportar: (a) => _showExportDialog(context, a, matriculaVm, turmas),
                    ),
                  if (total > 1) CatequizandoPagination(vm: vm, theme: theme),
                ],
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
    required ThemeData theme,
    required Color activeColor,
  }) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : cs.onSurfaceVariant,
        ),
        selectedColor: activeColor,
        backgroundColor: cs.surfaceContainerHighest.withOpacity(0.4),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? activeColor : cs.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildEmptyState({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


