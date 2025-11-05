import 'package:flutter/material.dart';
import 'package:neero_ttl_etag_cache/neero_ttl_etag_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NeeroTtlEtagCache.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSONPlaceholder Todo Cache',
      home: Scaffold(
        appBar: AppBar(title: const Text('Todos Cache + ETag')),
        body: const TodoList(),
      ),
    );
  }
}

// Modèle Todo
class Todo {
  final int id;
  final String title;
  final bool completed;
  Todo({required this.id, required this.title, required this.completed});

  factory Todo.fromJson(Map<String, dynamic> json) =>
      Todo(id: json['id'], title: json['title'], completed: json['completed']);
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Zone des boutons
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Invalidate le cache local
                  await NeeroTtlEtagCache.invalidate<List<Todo>>(
                    url: 'https://jsonplaceholder.typicode.com/todos',
                  );
                },
                child: const Text('Clear Local Cache'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  // Force refetch depuis le serveur
                  await NeeroTtlEtagCache.refetch<List<Todo>>(
                    url: 'https://jsonplaceholder.typicode.com/todos',
                    fromJson: (json) {
                      final list = json as List;
                      return list.map((e) => Todo.fromJson(e)).toList();
                    },
                    headers: {"accept": "application/json"},
                  );
                },
                child: const Text('Refetch Server'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Force refetch depuis le serveur
                  await NeeroTtlEtagCache.refetch<List<Todo>>(
                    url: 'https://jsonplaceholder.typicode.com/todos',
                    fromJson: (json) {
                      final list = json as List;
                      return list.map((e) => Todo.fromJson(e)).toList();
                    },
                    headers: {"accept": "application/json"},
                    forceRefresh: true,
                  );
                },
                child: const Text('Force Server'),
              ),
            ],
          ),
        ),
        // Zone liste avec cache réactif
        Expanded(
          child: GenericTtlEtagCacheViewer<List<Todo>>(
            url: 'https://jsonplaceholder.typicode.com/todos',
            method: 'GET',
            fromJson: (json) {
              final list = json as List;
              return list.map((e) => Todo.fromJson(e)).toList();
            },

            builder:
                (
                  context, {
                  data,
                  isStale = false,
                  isFetching = false,
                  error,
                  timestamp,
                  ttlSeconds,
                  etag,
                  onRetry,
                }) {
                  if (error != null && (data == null || data.isEmpty)) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Error: $error'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: onRetry,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (isFetching && (data == null || data.isEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final todos = data ?? [];

                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "IsLoading:${isFetching}, IsStale:${isStale}, Error:$error",
                          ),
                        ],
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async => onRetry?.call(),
                          child: ListView.builder(
                            itemCount: todos.length,
                            itemBuilder: (_, index) {
                              final todo = todos[index];
                              return ListTile(
                                title: Text(todo.title),
                                subtitle: Text(
                                  'Completed: ${todo.completed} | '
                                  'Stale: $isStale | TTL: ${ttlSeconds ?? 0}s | '
                                  'Updated: ${timestamp?.toLocal().toString() ?? '-'}',
                                  style: TextStyle(
                                    color: isStale
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
          ),
        ),
      ],
    );
  }
}
