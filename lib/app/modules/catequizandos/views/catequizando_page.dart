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
import 'catequizando_form.dart';
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
                                        '${DateFormat('MMM/yyyy').format(m.dataMatricula)}',
                                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                      ),
                                      if (m.dataConclusao != null) ...[
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 13, color: colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${DateFormat('MMM/yyyy').format(m.dataConclusao!)}',
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
                  if (historico.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () => CertificateGenerator.generateHistorico(catequizando, historico),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: const Text('Exportar PDF'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                      ),
                    ),
                  const SizedBox(width: 12),
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

  Future<void> _baixarArquivo(DocumentoAnexado doc) async {
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
                          const maxBytes = 1048576;
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
                              Get.snackbar('Arquivo muito grande', '${f.name} ultrapassa 1 MB.', snackPosition: SnackPosition.BOTTOM);
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

                                final driveFile = await driveService.uploadFile(
                                  bytes: bytes,
                                  nome: f.name,
                                  parentFolderId: pastaId,
                                );

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
                  label: Obx(() => Text(uploading.value ? 'Enviando...' : 'Adicionar documentos (PDF, Word — máx. 1 MB)')),
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
                                  onPressed: () => _baixarArquivo(doc),
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
  final screenWidth = MediaQuery.of(context).size.width;
  final dialogWidth = screenWidth > 900 ? 640.0 : screenWidth > 600 ? 560.0 : screenWidth * 0.95;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: CatequizandoForm(
          catequizando: catequizando,
          vm: vm,
          turmas: turmas,
          matriculaVm: Get.find<MatriculaViewModel>(),
          width: dialogWidth,
        ),
      ),
    ),
  );
}

class CatequizandoPage extends StatelessWidget {
  final CatequizandoViewModel vm;
  final List<TurmaModel> turmas;
  final MatriculaViewModel matriculaVm;
  const CatequizandoPage({
    super.key,
    required this.vm,
    this.turmas = const [],
    required this.matriculaVm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, hPad),
      children: [
        const SizedBox(height: 16),
        Obx(
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
        const SizedBox(height: 16),
        Obx(() {
          final paginated = vm.paginatedCatequizandos;
          final total = vm.totalPages;
          if (vm.catequizandos.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Nenhum catequizando encontrado',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    if (paginated.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'Nenhum resultado para essa busca',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: paginated.length,
                        itemBuilder: (_, i) => _CatequizandoCard(
                          aluno: paginated[i], theme: theme, vm: vm,
                          turmas: turmas, matriculaVm: matriculaVm,
                        ),
                      ),
                    if (total > 1) _PaginationControls(vm: vm, theme: theme),
                  ],
                );
              }
              return Column(
                children: [
                  if (paginated.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'Nenhum resultado para essa busca',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  else
                    _CatequizandoTable(
                      alunos: paginated, theme: theme, vm: vm,
                      turmas: turmas, matriculaVm: matriculaVm,
                    ),
                  if (total > 1) _PaginationControls(vm: vm, theme: theme),
                ],
              );
            },
          );
        }),
      ],
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'Em Andamento': return Colors.blue;
    case 'Formado': return Colors.green;
    case 'Desistente': return Colors.red;
    case 'Transferido': return Colors.orange;
    case 'Inativo': return Colors.grey;
    default: return Colors.grey;
  }
}

class _CatequizandoCard extends StatelessWidget {
  final Catequizando aluno;
  final ThemeData theme;
  final CatequizandoViewModel vm;
  final List<TurmaModel> turmas;
  final MatriculaViewModel matriculaVm;

  const _CatequizandoCard({
    required this.aluno,
    required this.theme,
    required this.vm,
    this.turmas = const [],
    required this.matriculaVm,
  });

  @override
  Widget build(BuildContext context) {
    final turmaNome = matriculaVm.getNomeTurmaAtual(aluno.id, turmas) ?? '';
    final tempoLongo = matriculaVm.getTemTempoLongo(aluno.id);
    final meses = matriculaVm.mesesNaTurmaAtual(aluno.id);
    final corStatus = _statusColor(aluno.status);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Text(
                  aluno.nome[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aluno.nome,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book_rounded, size: 13, color: tempoLongo ? Colors.orange.shade700 : theme.colorScheme.onSurface.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Flexible(child: Text(turmaNome, style: theme.textTheme.bodySmall?.copyWith(color: tempoLongo ? Colors.orange.shade700 : null), overflow: TextOverflow.ellipsis)),
                            if (tempoLongo) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.schedule_rounded, size: 13, color: Colors.orange.shade700),
                            ],
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: corStatus.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: corStatus),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                aluno.status,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: corStatus,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _infoChip(Icons.person_outline, aluno.responsavel, theme),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${aluno.idade}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                        Text(
                          'anos',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(Icons.history_rounded, color: theme.colorScheme.tertiary),
                          onPressed: () => showHistoricoDialog(context, aluno, matriculaVm, turmas),
                          tooltip: 'Histórico',
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                          onPressed: () => showEditarCatequizandoDialog(context, vm, catequizando: aluno, turmas: turmas, ),
                          tooltip: 'Editar',
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Confirmar Exclusão'),
                                content: Text('Deseja excluir "${aluno.nome}"?'),
                                actions: [
                                  TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                                  FilledButton(
                                    onPressed: () {
                                      vm.removeCatequizando(aluno.id);
                                      Get.back();
                                    },
                                    style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'Excluir',
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(Icons.folder_outlined, color: theme.colorScheme.tertiary),
                          onPressed: () => showDocumentosDialog(context, vm, catequizando: aluno),
                          tooltip: 'Documentos',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 4),
        Flexible(child: Text(label, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _CatequizandoTable extends StatefulWidget {
  final List<Catequizando> alunos;
  final ThemeData theme;
  final CatequizandoViewModel vm;
  final List<TurmaModel> turmas;
  final MatriculaViewModel matriculaVm;

  const _CatequizandoTable({
    required this.alunos,
    required this.theme,
    required this.vm,
    this.turmas = const [],
    required this.matriculaVm,
  });

  @override
  State<_CatequizandoTable> createState() => _CatequizandoTableState();
}

class _CatequizandoTableState extends State<_CatequizandoTable> {
  void _sort(int col) {
    widget.vm.sortBy(col);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final alunos = widget.alunos;
    final sortCol = widget.vm.sortColumn.value;
    final sortAsc = widget.vm.sortAscending.value;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.3),
          4: FlexColumnWidth(2),
          5: FixedColumnWidth(80),
          6: FixedColumnWidth(164),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3), width: 0.5),
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3), width: 0.5),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.85),
                ],
              ),
            ),
            children: [
              const SizedBox.shrink(),
              _sortableHeader('Nome', Icons.person_rounded, 1, sortCol, sortAsc),
              _sortableHeader('Turma', Icons.menu_book_rounded, 2, sortCol, sortAsc),
              _sortableHeader('Status', Icons.info_outline_rounded, 3, sortCol, sortAsc),
              _sortableHeader('Responsável', Icons.phone_rounded, 4, sortCol, sortAsc),
              _sortableHeader('Idade', Icons.cake_rounded, 5, sortCol, sortAsc),
              _headerCell('Ações', Icons.touch_app_rounded),
            ],
          ),
          ...alunos.asMap().entries.map(
            (entry) {
              final i = entry.key;
              final a = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: i.isOdd
                      ? theme.colorScheme.surfaceContainerLow.withOpacity(0.4)
                      : Colors.transparent,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Text(
                        a.nome[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  _bodyCell(a.nome, isBold: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.matriculaVm.getTemTempoLongo(a.id)
                            ? Colors.orange.withOpacity(0.15)
                            : theme.colorScheme.primaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.matriculaVm.getNomeTurmaAtual(a.id, widget.turmas) ?? '',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: widget.matriculaVm.getTemTempoLongo(a.id)
                                  ? Colors.orange.shade700
                                  : theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          if (widget.matriculaVm.getTemTempoLongo(a.id)) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.schedule_rounded, size: 13, color: Colors.orange.shade700),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(a.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: _statusColor(a.status)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            a.status,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _statusColor(a.status),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            a.telefone,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${a.idade}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.tertiary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.history_rounded, size: 18, color: theme.colorScheme.tertiary),
                            onPressed: () => showHistoricoDialog(context, a, widget.matriculaVm, widget.turmas),
                            tooltip: 'Histórico',
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
                            onPressed: () => showEditarCatequizandoDialog(context, widget.vm, catequizando: a, turmas: widget.turmas),
                            tooltip: 'Editar',
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Confirmar Exclusão'),
                                  content: Text('Deseja excluir "${a.nome}"?'),
                                  actions: [
                                    TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                                    FilledButton(
                                      onPressed: () {
                                        widget.vm.removeCatequizando(a.id);
                                        Get.back();
                                      },
                                      style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            tooltip: 'Excluir',
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.folder_outlined, size: 18, color: theme.colorScheme.tertiary),
                            onPressed: () => showDocumentosDialog(context, widget.vm, catequizando: a),
                            tooltip: 'Documentos',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sortableHeader(String label, IconData icon, int col, int sortCol, bool sortAsc) {
    final theme = widget.theme;
    final isActive = sortCol == col;
    return InkWell(
      onTap: () => _sort(col),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                sortAsc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 14,
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String label, IconData icon) {
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: theme.colorScheme.onPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Padding _bodyCell(String text, {bool isBold = false}) {
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: isBold
            ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
            : theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final CatequizandoViewModel vm;
  final ThemeData theme;

  const _PaginationControls({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final total = vm.totalPages;
    final current = vm.currentPage.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: current > 0 ? vm.prevPage : null,
            tooltip: 'Anterior',
          ),
          const SizedBox(width: 8),
          ..._buildPageNumbers(total, current),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: current < total - 1 ? vm.nextPage : null,
            tooltip: 'Próximo',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int total, int current) {
    final pages = <Widget>[];
    final int start;
    final int end;

    if (total <= 7) {
      start = 0;
      end = total;
    } else {
      start = (current - 2).clamp(0, total - 5);
      end = (start + 5).clamp(0, total);
    }

    if (start > 0) {
      pages.add(_pageChip(0, current));
      pages.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('...'),
      ));
    }

    for (var i = start; i < end; i++) {
      pages.add(_pageChip(i, current));
    }

    if (end < total) {
      pages.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('...'),
      ));
      pages.add(_pageChip(total - 1, current));
    }

    return pages;
  }

  Widget _pageChip(int page, int current) {
    final isActive = page == current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 36,
        height: 36,
        child: isActive
            ? FilledButton.tonal(
                onPressed: null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(36, 36),
                ),
                child: Text(
                  '${page + 1}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              )
            : TextButton(
                onPressed: () => vm.goToPage(page),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  '${page + 1}',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                ),
              ),
      ),
    );
  }
}
