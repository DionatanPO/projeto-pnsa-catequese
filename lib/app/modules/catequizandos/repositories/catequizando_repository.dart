import '../models/catequizando_model.dart';

class CatequizandoRepository {
  final List<Catequizando> _mockData = [
    Catequizando(nome: 'Ana Beatriz Souza', dataNascimento: DateTime(2016, 5, 12), turmaNome: '1ª Eucaristia - A', batizado: true, localBatismo: 'Matriz São Sebastião', responsavel: 'Maria Souza', parentesco: 'Mãe', telefone: '(62) 99901-1001'),
    Catequizando(nome: 'Lucas Eduardo Costa', dataNascimento: DateTime(2015, 8, 3), turmaNome: '1ª Eucaristia - A', batizado: true, responsavel: 'João Costa', parentesco: 'Pai', telefone: '(62) 99901-1002'),
    Catequizando(nome: 'Marina Clara Alves', dataNascimento: DateTime(2016, 2, 20), turmaNome: '1ª Eucaristia - B', batizado: true, responsavel: 'Carla Alves', parentesco: 'Mãe', telefone: '(62) 99901-1003'),
    Catequizando(nome: 'Felipe Augusto Lima', dataNascimento: DateTime(2015, 11, 7), turmaNome: '1ª Eucaristia - B', batizado: true, responsavel: 'Pedro Lima', parentesco: 'Pai', telefone: '(62) 99901-1004'),
    Catequizando(nome: 'Gabriela Rocha Martins', dataNascimento: DateTime(2014, 4, 15), turmaNome: '2ª Eucaristia - A', batizado: true, responsavel: 'Rita Martins', parentesco: 'Mãe', telefone: '(62) 99901-1005'),
    Catequizando(nome: 'Vinícius Santos Oliveira', dataNascimento: DateTime(2014, 7, 22), turmaNome: '2ª Eucaristia - A', batizado: true, responsavel: 'Carlos Oliveira', parentesco: 'Pai', telefone: '(62) 99901-1006'),
    Catequizando(nome: 'Isabela Cristina Pereira', dataNascimento: DateTime(2013, 1, 30), turmaNome: '2ª Eucaristia - B', batizado: true, responsavel: 'Ana Pereira', parentesco: 'Mãe', telefone: '(62) 99901-1007'),
    Catequizando(nome: 'Enzo Gabriel Nunes', dataNascimento: DateTime(2014, 9, 14), turmaNome: '2ª Eucaristia - B', batizado: true, responsavel: 'Ricardo Nunes', parentesco: 'Pai', telefone: '(62) 99901-1008'),
    Catequizando(nome: 'Sofia Helena Araújo', dataNascimento: DateTime(2011, 3, 5), turmaNome: 'Crisma - A', batizado: true, fezPrimeiraEucaristia: true, responsavel: 'Lúcia Araújo', parentesco: 'Mãe', telefone: '(62) 99901-1009'),
    Catequizando(nome: 'Matheus Henrique Barbosa', dataNascimento: DateTime(2010, 6, 18), turmaNome: 'Crisma - A', batizado: true, fezPrimeiraEucaristia: true, responsavel: 'Paulo Barbosa', parentesco: 'Pai', telefone: '(62) 99901-1010'),
    Catequizando(nome: 'Laura Vitória Cardoso', dataNascimento: DateTime(2011, 10, 25), turmaNome: 'Crisma - B', batizado: true, fezPrimeiraEucaristia: true, responsavel: 'Fernanda Cardoso', parentesco: 'Mãe', telefone: '(62) 99901-1011'),
    Catequizando(nome: 'João Miguel Teixeira', dataNascimento: DateTime(2010, 12, 2), turmaNome: 'Crisma - B', batizado: true, fezPrimeiraEucaristia: true, responsavel: 'Roberto Teixeira', parentesco: 'Pai', telefone: '(62) 99901-1012'),
    Catequizando(nome: 'Júlia Fernandes Ribeiro', dataNascimento: DateTime(2018, 4, 8), turmaNome: 'Cordeirinhos', batizado: false, responsavel: 'Teresa Ribeiro', parentesco: 'Mãe', telefone: '(62) 99901-1013'),
    Catequizando(nome: 'Rafael Carvalho Dias', dataNascimento: DateTime(2019, 7, 19), turmaNome: 'Cordeirinhos', batizado: false, responsavel: 'Sônia Dias', parentesco: 'Mãe', telefone: '(62) 99901-1014'),
    Catequizando(nome: 'Camila Oliveira Campos', dataNascimento: DateTime(2009, 2, 28), turmaNome: 'Perseverança', batizado: true, fezPrimeiraEucaristia: true, responsavel: 'Márcia Campos', parentesco: 'Mãe', telefone: '(62) 99901-1015'),
  ];

  List<Catequizando> getAll() => List.unmodifiable(_mockData);

  Future<void> add(Catequizando catequizando) async {
    _mockData.add(catequizando);
  }

  Future<void> update(Catequizando catequizando) async {
    final idx = _mockData.indexWhere((a) => a.id == catequizando.id);
    if (idx != -1) {
      _mockData[idx] = catequizando;
    }
  }

  Future<void> remove(String id) async {
    _mockData.removeWhere((a) => a.id == id);
  }
}
