import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';
import 'package:postgres/postgres.dart';

final connection = PostgreSQLConnection(
  'localhost', // Url do servidor onde o banco esta alocado
  5432, // Porta receptora das requisições
  'postgres', // Nome do banco de dados
  username: 'postgres', // Usuário do banco de dados
  password: 'admin', // Sua senha do banco de dados
);

void main() async {
  await connection.open();

  final router = Router();

  router.post('/usuarios', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final nome = data['nome'];
    if (nome == null || nome.toString().isEmpty) {
      return Response(
        400,
        body: jsonEncode({'erro': 'Nome é obrigatório'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    await connection.query(
      'INSERT INTO usuario (nome) VALUES (@nome)',
      substitutionValues: {'nome': nome},
    );

    return Response.ok(
      jsonEncode({'mensagem': 'Usuário cadastrado com sucesso', 'nome': nome}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router);

  await io.serve(handler, '0.0.0.0', 8080);
}

