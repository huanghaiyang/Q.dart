import 'package:Q/Q.dart';
import 'package:Q/src/database/Database.dart';
import 'package:Q/src/database/Entity.dart';
import 'package:Q/src/database/Repository.dart';
import 'package:Q/src/database/PostgreSQLConnection.dart';
import 'package:Q/src/database/DatabaseConnectionPoolImpl.dart';
import 'package:Q/src/database/DatabaseConnectionPool.dart';

@Entity(tableName: 'users')
class User {
  @Column(isPrimaryKey: true, autoIncrement: true)
  int id;

  @Column(length: 100, nullable: false)
  String username;

  @Column(length: 255, nullable: false)
  String email;

  @Column(length: 255, nullable: false)
  String passwordHash;

  @Column(length: 50, nullable: false)
  String role;

  User({this.id, this.username, this.email, this.passwordHash, this.role});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      role: json['role'] as String,
    );
  }
}

class UserRepository extends BaseRepository<User> {
  UserRepository(DatabaseConnectionPool connectionPool) : super(
    connectionPool: connectionPool,
    tableName: 'users',
    primaryKey: 'id',
  );

  @override
  User fromMap(Map<String, dynamic> map) {
    return User.fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(User entity) {
    return {
      'username': entity.username,
      'email': entity.email,
      'passwordHash': entity.passwordHash,
      'role': entity.role,
    };
  }

  Future<User> findByUsername(String username) async {
    final results = await connectionPool.query(
      'SELECT * FROM users WHERE username = @1',
      params: [username],
    );
    if (results.isEmpty) return null;
    return fromMap(results.first);
  }
}

void main() async {
  Application app = Application();
  await app.init();

  print('PostgreSQL Example Starting...');

  final connectionFactory = () async {
    return PostgreSQLConnection(
      host: 'localhost',
      port: 5432,
      database: 'test_db',
      username: 'postgres',
      password: 'password',
    );
  };

  final connectionPool = DatabaseConnectionPoolImpl(
    config: DatabasePoolConfig(
      maxConnections: 10,
      minConnections: 2,
      maxLifetime: 3600000,
    ),
    connectionFactory: connectionFactory,
  );

  print('Connected to PostgreSQL database');

  final userRepository = UserRepository(connectionPool);

  try {
    await connectionPool.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(100) NOT NULL,
        email VARCHAR(255) NOT NULL,
        passwordHash VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    print('Created users table');

    final newUser = User(
      username: 'test_user',
      email: 'test@example.com',
      passwordHash: 'hashed_password',
      role: 'user',
    );

    final userId = await userRepository.insert(newUser);
    print('Inserted user with ID: $userId');

    final foundUser = await userRepository.findById(userId);
    print('Found user: ${foundUser?.toJson()}');

    final foundByUsername = await userRepository.findByUsername('test_user');
    print('Found by username: ${foundByUsername?.toJson()}');

    foundUser.role = 'admin';
    await userRepository.update(foundUser);
    print('Updated user role to admin');

    final allUsers = await userRepository.findAll();
    print('All users: ${allUsers.map((u) => u.toJson()).toList()}');

    await userRepository.delete(userId);
    print('Deleted user');

  } catch (e) {
    print('Error: $e');
  } finally {
    await connectionPool.close();
    print('Connection pool closed');
  }

  print('PostgreSQL Example Completed');
}
