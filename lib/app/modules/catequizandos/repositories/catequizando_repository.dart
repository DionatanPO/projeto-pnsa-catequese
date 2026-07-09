import '../models/catequizando_model.dart';

class CatequizandoRepository {
  final List<Catequizando> _mockData = () {
    final nomes = [
      'Ana Beatriz Souza', 'Lucas Eduardo Costa', 'Marina Clara Alves',
      'Felipe Augusto Lima', 'Gabriela Rocha Martins', 'Vinícius Santos Oliveira',
      'Isabela Cristina Pereira', 'Enzo Gabriel Nunes', 'Sofia Helena Araújo',
      'Matheus Henrique Barbosa', 'Laura Vitória Cardoso', 'João Miguel Teixeira',
      'Júlia Fernandes Ribeiro', 'Rafael Carvalho Dias', 'Camila Oliveira Campos',
      'Pedro Henrique Almeida', 'Alice Moreira Santos', 'Bernardo Gomes da Silva',
      'Valentina Oliveira Costa', 'Heitor Souza Martins', 'Lara Cunha Pereira',
      'Davi Lucca Barbosa', 'Maria Clara Nascimento', 'Henrique Batista Silva',
      'Manuela Cardoso Ribeiro', 'Murilo Rocha Azevedo', 'Giovanna Ferreira Dias',
      'Gustavo Lima Barbosa', 'Isadora Campos Moreira', 'Arthur Costa Fernandes',
      'Cecília Martins Rocha', 'Samuel Oliveira Souza', 'Heloísa Pereira Santos',
      'Bento Santos Lima', 'Esther Ribeiro Costa', 'Thiago Alves Correia',
      'Rafaela Silva Mendes', 'Lorenzo Souza Araújo', 'Mariana Barbosa Almeida',
      'Nicolas Oliveira Barros', 'Vitória Carvalho Nunes', 'Cauã Santos Teixeira',
      'Elisa Rocha Martins', 'Luiz Felipe Costa', 'Antônia Rodrigues Pereira',
      'Theo Souza Carvalho', 'Bianca Lima Gomes', 'Bryan Oliveira Souza',
      'Clara Ribeiro Barbosa', 'Vicente Santos Neto', 'Margarida Fernandes Santos',
      'Antônio Carlos Silva', 'Lívia Azevedo Moreira', 'João Pedro Oliveira',
      'Beatriz Campos Rocha', 'Miguel Torres Alves', 'Sophia Martins Cunha',
      'Noah Pereira Lima', 'Isis Barbosa Santos', 'Gabriel Costa Rodrigues',
      'Valentina Sales Silva', 'Rafael Nunes Pereira', 'Melissa Oliveira Santos',
      'Augusto Lima Fernandes', 'Maria Eduarda Costa', 'Anthony Rocha Barbosa',
      'Lorena Marques Almeida', 'Benício Souza Gomes', 'Lavínia Dias Carvalho',
      'Felipe Silva Araújo', 'Alice Fernanda Rocha', 'Daniel Oliveira Barbosa',
      'Helena Cristina Souza', 'Kaique Santos Pereira', 'Larissa Gomes Silva',
      'Lucas Henrique Costa', 'Sara Martins Ribeiro', 'Otávio Souza Almeida',
      'Júlia Carvalho Santos', 'Pedro Augusto Silva', 'Emanuelly Oliveira Costa',
      'Bruno Rocha Martins', 'Luiza Pereira Barbosa', 'Mateus Almeida Santos',
      'Yasmin Gonçalves Silva', 'Erick Souza Costa', 'Emilly Ribeiro Oliveira',
      'Vitor Hugo Pereira', 'Fernanda Lima Carvalho', 'Calebe Martins Souza',
      'Amanda Rocha Silva', 'Vinicius Alves Souza', 'Sabrina Santos Oliveira',
      'Leonardo Costa Pereira', 'Pietra Almeida Barbosa', 'Cauã Henrique Silva',
      'Letícia Ramos Oliveira', 'Raul Souza Silva', 'Ana Júlia Moreira Costa',
      'Thales Carvalho Souza', 'Natália Rocha Araújo', 'Ian Barbosa Lima',
      'Mirella Santos Gomes', 'Felipe Henrique Dias', 'Gabrielly Oliveira Rocha',
      'Eduardo Lima Silva', 'Giovana Martins Souza', 'Breno Costa Almeida',
      'Emanuelle Pereira Santos', 'Cláudio Henrique Barbosa', 'Raquel Oliveira Silva',
      'Luiz Gustavo Souza', 'Mariana Rocha Carvalho', 'José Carlos Almeida',
      'Aline Silva Santos', 'Ruan Moreira Costa', 'Tatiane Oliveira Barros',
      'Diogo Fernandes Lima', 'Andressa Pereira Rocha', 'Fábio Santos Araújo',
      'Bruna Carvalho Costa', 'Rodrigo Alves Silva', 'Tainá Oliveira Souza',
      'Márcio Barbosa Santos', 'Priscila Rocha Silva', 'Leandro Costa Pereira',
      'Jéssica Almeida Oliveira', 'Anderson Lima Santos', 'Vanessa Martins Silva',
      'Ramon Souza Barbosa', 'Carla Santos Pereira', 'Tiago Oliveira Costa',
    ];

    final statuses = ['Em Andamento', 'Em Andamento', 'Em Andamento', 'Em Andamento', 'Formado', 'Desistente', 'Transferido', 'Inativo'];
    final parentescos = ['Mãe', 'Pai', 'Avó', 'Avô', 'Tia', 'Tio', 'Madrinha', 'Padrinho'];
    final telefones = List.generate(nomes.length, (i) => '(62) 999${(100 + i).toString().padLeft(4, '0')}-${(1000 + i).toString().padLeft(4, '0')}');
    return List.generate(nomes.length, (i) {
      final nome = nomes[i];
      final ano = 2009 + (i % 10);
      final mes = 1 + (i % 12);
      final dia = 1 + (i % 28);
      return Catequizando(
        id: 'mock_$i',
        nome: nome,
        dataNascimento: DateTime(ano, mes, dia),
        batizado: i % 15 != 0,
        localBatismo: i % 3 == 0 && i % 15 != 0 ? 'Matriz São Sebastião' : i % 3 == 1 && i % 15 != 0 ? 'Paróquia Santa Maria' : i % 3 == 2 && i % 15 != 0 ? 'Paróquia Santo Antônio' : null,
        fezPrimeiraEucaristia: i % 4 == 0 ? true : null,
        responsavel: 'Responsável ${nome.split(' ').last}',
        parentesco: parentescos[i % parentescos.length],
        telefone: telefones[i],
        cep: '74210-${(i + 10).toString().padLeft(3, '0')}',
        endereco: 'Rua ${['das Flores', 'dos Pinheiros', 'da Paz', 'do Sol', 'das Acácias', 'dos Lírios', 'da Esperança', 'do Carmo'][i % 8]}',
        numero: '${100 + i}',
        bairro: ['Setor Central', 'Jardim América', 'Vila Nova', 'Boa Vista', 'Santa Helena', 'Novo Horizonte', 'Bela Vista', 'Parque Verde'][i % 8],
        possuiRestricao: i % 10 == 0,
        detalheRestricao: i % 10 == 0 ? 'Alergia a ${['pólen', 'lactose', 'glúten', 'medicamento'][i % 4]}' : null,
        status: statuses[i % statuses.length],
      );
    });
  }();

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
