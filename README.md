# neero_ttl_etag_cache

A new Flutter plugin project.

## Getting Started

Add the package to your pubspec.yaml file:

```yaml
dependencies:
  neero_ttl_etag_cache: ^0.0.1
```

Initialize the cache:

```Dart
ReactiveCacheDio().init();
```

You can optionally pass a Dio instance to the init method:

```Dart
ReactiveCacheDio().init(dio: Dio());
```


## Example
```Dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late final CachedTtlEtagRepository<MyModel> _repository;

  @override
  void initState() {
    super.initState();
    _repository = CachedTtlEtagRepository<MyModel>(
      url: 'https://api.example.com/data',
      fromJson: (json) => MyModel.fromJson(json),
      defaultTtl: Duration(minutes: 5),
    );
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cached Data'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _repository.refresh(),
          ),
        ],
      ),
      body: StreamBuilder<CacheTtlEtagState<MyModel>>(
        stream: _repository.stream,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const CacheTtlEtagState();

          // Empty state
          if (state.isEmpty) {
            return Center(child: Text('No data'));
          }

          // Error without cached data
          if (state.hasError && !state.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${state.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _repository.fetch(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Content with loading/error overlays
          return Stack(
            children: [
              // Main content
              RefreshIndicator(
                onRefresh: () => _repository.refresh(),
                child: ListView(
                  children: [
                    // Stale indicator
                    if (state.isStale)
                      Container(
                        color: Colors.orange.shade100,
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, size: 16),
                            SizedBox(width: 8),
                            Text('Data is stale, refreshing...'),
                          ],
                        ),
                      ),
                    
                    // Cache info (optional)
                    if (state.timestamp != null)
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Last updated: ${state.timestamp!.toLocal()}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),

                    // Your content
                    if (state.hasData)
                      ...buildContent(state.data!),
                  ],
                ),
              ),

              // Loading indicator
              if (state.isLoading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),

              // Error snackbar (when we have cached data)
              if (state.hasError && state.hasData)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('Failed to refresh: ${state.error}'),
                          ),
                          TextButton(
                            onPressed: () => _repository.fetch(),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> buildContent(MyModel data) {
    return [
      ListTile(
        title: Text(data.title),
        subtitle: Text(data.description),
      ),
      // ... more widgets
    ];
  }
}

```