import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/google_drive_service.dart';

class ConfiguracaoDrivePage extends StatefulWidget {
  const ConfiguracaoDrivePage({super.key});

  @override
  State<ConfiguracaoDrivePage> createState() => _ConfiguracaoDrivePageState();
}

class _ConfiguracaoDrivePageState extends State<ConfiguracaoDrivePage> {
  final _driveService = Get.find<GoogleDriveService>();
  bool _connecting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conectado = _driveService.isReady;
    final email = _driveService.emailLogado;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuração do Google Drive')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      conectado ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                      color: conectado ? Colors.green : Colors.grey,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conectado ? 'Conectado' : 'Desconectado',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (email != null) ...[
                            const SizedBox(height: 4),
                            Text(email, style: theme.textTheme.bodySmall),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            conectado
                                ? 'O sistema está usando esta conta para armazenar os arquivos no Google Drive.'
                                : 'Conecte uma conta do Google para armazenar os arquivos do sistema.',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text('Como funciona', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'O sistema utiliza a conta compartilhada sistemapnsacatequese@gmail.com '
                      'para armazenar todos os arquivos enviados (documentos dos catequizandos, '
                      'fotos, certificados, etc.) no Google Drive da paróquia.',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Conecte-se com essa conta para que o sistema possa acessar e gerenciar '
                      'os arquivos. Não use sua conta pessoal.',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'O sistema só aceita essa conta. Conectar com outra resultará em erro.',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 400,
                child: _connecting
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton.icon(
                        onPressed: conectado ? _desconectar : _conectar,
                        icon: Icon(conectado ? Icons.logout_rounded : Icons.login_rounded),
                        label: Text(conectado ? 'Desconectar conta' : 'Conectar com Google'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
              ),
            ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Future<void> _conectar() async {
    setState(() => _connecting = true);
    try {
      await _driveService.signIn();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao conectar: $e');
    } finally {
      setState(() => _connecting = false);
    }
  }

  Future<void> _desconectar() async {
    try {
      await _driveService.signOut();
      setState(() {});
      Get.snackbar('Desconectado', 'Conta do Google Drive removida.');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao desconectar: $e');
    }
  }
}
