# 🚀 **Required Jenkins Plugins**

Install via:
**Manage Jenkins → Plugins → Available**

### ✅ **Core CI/CD**

* **Docker**
* **Docker Pipeline**
* **Pipeline Utility Steps**

### 🎨 **UI & Visualization**

* **Blue Ocean**

---

# ⚙️ **Recommended System Configuration**

To allow Playwright reports, HTML reports, and static assets to load correctly inside Jenkins (fixes CSP blocking inline scripts/styles), run this in:

**Manage Jenkins → Script Console**

```groovy
System.setProperty(
    "hudson.model.DirectoryBrowserSupport.CSP",
    "default-src 'self' 'unsafe-inline' 'unsafe-eval';"
)
```