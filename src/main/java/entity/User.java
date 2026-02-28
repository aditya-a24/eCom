package entity;

import jakarta.persistence.*;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

@Entity
@Table(name = "users")
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false)
    private String name;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role; // "user", "vendor", "admin"

    /**
     * Vendor verification flag.
     * - For role="vendor": false = pending approval, true = verified by admin.
     * - For role="user": always true (auto-verified on registration).
     */
    @Column(nullable = false)
    private boolean verified = true;

    public User() {}

    public User(String name, String email, String password, String role) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        // Vendors start unverified; users are auto-verified
        this.verified = !"vendor".equals(role);
    }

    // Getters and Setters
    public int getId()             { return id; }
    public void setId(int id)      { this.id = id; }

    public String getName()           { return name; }
    public void setName(String name)  { this.name = name; }

    public String getEmail()              { return email; }
    public void setEmail(String email)    { this.email = email; }

    public String getPassword()                { return password; }
    public void setPassword(String password)   { this.password = password; }

    public String getRole()            { return role; }
    public void setRole(String role)   { this.role = role; }

    public boolean isVerified()               { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }
}
