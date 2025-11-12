package com.example;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Random;

/**
 * Data Generator for REST API Performance Testing
 * Generates 2000 categories and 100,000 items
 */
public class DataGenerator {

    private static final int CATEGORIES_COUNT = 2000;
    private static final int ITEMS_COUNT = 100000;
    private static final int BATCH_SIZE = 1000;

    public static void main(String[] args) {
        String jdbcUrl = System.getenv().getOrDefault("DB_URL", "jdbc:postgresql://localhost:5432/rest_api_perf");
        String username = System.getenv().getOrDefault("DB_USER", "perfuser");
        String password = System.getenv().getOrDefault("DB_PASSWORD", "perfpass");

        System.out.println("=== REST API Performance Test Data Generator ===");
        System.out.println("Database: " + jdbcUrl);
        System.out.println("Generating " + CATEGORIES_COUNT + " categories and " + ITEMS_COUNT + " items...\n");

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(jdbcUrl);
        config.setUsername(username);
        config.setPassword(password);
        config.setMaximumPoolSize(10);
        config.setAutoCommit(false);

        try (HikariDataSource dataSource = new HikariDataSource(config)) {
            long startTime = System.currentTimeMillis();

            generateCategories(dataSource);
            generateItems(dataSource);

            long endTime = System.currentTimeMillis();
            System.out.println("\n✓ Data generation completed in " + (endTime - startTime) + " ms");

        } catch (Exception e) {
            System.err.println("✗ Error generating data: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void generateCategories(HikariDataSource dataSource) throws SQLException {
        System.out.println("Generating categories...");
        String sql = "INSERT INTO category (name, description) VALUES (?, ?)";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            for (int i = 1; i <= CATEGORIES_COUNT; i++) {
                stmt.setString(1, "Category " + i);
                stmt.setString(2, "Description for category " + i + 
                    ". This is a test category with some longer text to simulate real data.");
                stmt.addBatch();

                if (i % BATCH_SIZE == 0) {
                    stmt.executeBatch();
                    conn.commit();
                    System.out.printf("  Progress: %d/%d categories (%.1f%%)%n", 
                        i, CATEGORIES_COUNT, (i * 100.0 / CATEGORIES_COUNT));
                }
            }

            stmt.executeBatch();
            conn.commit();
            System.out.println("✓ " + CATEGORIES_COUNT + " categories generated");
        }
    }

    private static void generateItems(HikariDataSource dataSource) throws SQLException {
        System.out.println("\nGenerating items...");
        String sql = "INSERT INTO item (name, description, price, quantity, category_id) VALUES (?, ?, ?, ?, ?)";
        Random random = new Random();

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            for (int i = 1; i <= ITEMS_COUNT; i++) {
                stmt.setString(1, "Item " + i);
                stmt.setString(2, "Description for item " + i + 
                    ". This item belongs to a category and has various properties for testing purposes.");
                stmt.setDouble(3, Math.round((random.nextDouble() * 999 + 1) * 100.0) / 100.0);
                stmt.setInt(4, random.nextInt(1000));
                stmt.setLong(5, random.nextInt(CATEGORIES_COUNT) + 1);
                stmt.addBatch();

                if (i % BATCH_SIZE == 0) {
                    stmt.executeBatch();
                    conn.commit();
                    System.out.printf("  Progress: %d/%d items (%.1f%%)%n", 
                        i, ITEMS_COUNT, (i * 100.0 / ITEMS_COUNT));
                }
            }

            stmt.executeBatch();
            conn.commit();
            System.out.println("✓ " + ITEMS_COUNT + " items generated");
        }
    }
}
