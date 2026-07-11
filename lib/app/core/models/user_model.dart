class UserModel {
  final String id;
  final String nome;
  final String email;
  final String role;
  final String telefone;
  final String area;
  final bool ativo;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    this.role = 'catequista',
    this.telefone = '',
    this.area = '',
    this.ativo = true,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      nome: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'catequista',
      telefone: map['telefone'] as String? ?? '',
      area: map['area'] as String? ?? '',
      ativo: map['ativo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'role': role,
      'telefone': telefone,
      'area': area,
      'ativo': ativo,
    };
  }
}
