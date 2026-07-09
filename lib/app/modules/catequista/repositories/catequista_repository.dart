import '../models/catequista_model.dart';

class CatequistaRepository {
  final List<Catequista> _items = [];

  CatequistaRepository() {
    _loadMockData();
  }

  void _loadMockData() {
    if (_items.isNotEmpty) return;

    final statusList = ['Ativo', 'Ativo', 'Ativo', 'Ativo', 'Inativo', 'Afastado'];
    final nomes = [
      'Ana Clara Silva', 'Beatriz Souza Oliveira', 'Carlos Eduardo Pereira',
      'Daniela Santos Lima', 'Eduardo Almeida Costa', 'Fernanda Oliveira Martins',
      'Gabriel Barbosa Rocha', 'Helena Cristina Dias', 'Igor Nascimento Teixeira',
      'Juliana Costa Mendes', 'Kevin William Araújo', 'Larissa Fernanda Vieira',
      'Marcelo Henrique Gomes', 'Natália Beatriz Ribeiro', 'Otávio Augusto Carvalho',
      'Patrícia Aparecida Moreira', 'Raul César Azevedo', 'Sabrina Helena Farias',
      'Thiago Martins Correia', 'Ursula Cristina Pinto', 'Vinícius Santos Nogueira',
      'Wagner Luiz Barbosa', 'Yasmin Oliveira Campos', 'Zilda Maria Cardoso',
      'Adriana Ferreira Lopes', 'Bruno César Rocha', 'Cíntia Marques Soares',
      'Diego Henrique Castro', 'Elaine Cristina Freitas', 'Felipe Augusto Duarte',
      'Gabriela Nunes Peixoto', 'Humberto Alves Neto', 'Isabela Cristina Fogaça',
      'João Pedro Vasconcelos', 'Karen Santos Oliveira', 'Leonardo Ribeiro Bastos',
      'Márcia Helena Padilha', 'Nelson Eduardo Tavares', 'Olívia Campos Menezes',
      'Paulo Sérgio Antunes', 'Renata Cristina Machado', 'Sérgio Murilo Figueiredo',
      'Tatiana Oliveira Lira', 'Ubirajara Santos Melo', 'Vanessa Cristina Borges',
      'Wellington Dias Cabral', 'Xavier Almeida Prado', 'Amanda Lúcia Vargas',
    ];

    for (var i = 0; i < nomes.length; i++) {
      _items.add(Catequista(
        id: (i + 1).toString(),
        nome: nomes[i],
        email: '${nomes[i].split(' ').first.toLowerCase()}@email.com',
        telefone: '(11) 9${(90000 + i).toString().padLeft(5, '0')}-${(1000 + i).toString().padLeft(4, '0')}',
        status: statusList[i % statusList.length],

      ));
    }
  }

  List<Catequista> getAll() => List.unmodifiable(_items);

  Future<void> add(Catequista c) async {
    _items.add(c);
  }

  Future<void> update(Catequista c) async {
    final i = _items.indexWhere((e) => e.id == c.id);
    if (i != -1) _items[i] = c;
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
  }
}
