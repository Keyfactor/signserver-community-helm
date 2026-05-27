<!--SignServer Community logo for light and dark mode -->
<a href="https://signserver.org">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset=".github/community-signserver.png?raw=true">
    <source media="(prefers-color-scheme: dark)" srcset=".github/community-signserver-lite.png?raw=true">
    <img alt="SignServer Community" src=".github/community-signserver.png?raw=true" title="SignServer Community" height="70" >
  </picture>
</a>
<!--SignServer Enterprise logo for light and dark mode -->
<a href="https://www.keyfactor.com/products/signserver-enterprise/">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset=".github/keyfactor-signserver-enterprise.png?raw=true">
    <source media="(prefers-color-scheme: dark)" srcset=".github/keyfactor-signserver-enterprise-lite.png?raw=true">
    <img alt="SignServer Enterprise" src=".github/keyfactor-signserver-enterprise.png?raw=true" title="SignServer Enterprise" height="70" >
  </picture>
</a>

##

* **SignServer Community** (SignServer CE) - free and open source, OSI Certified Open Source Software, LGPL-licensed subset of SignServer Enterprise
* **SignServer Enterprise** (SignServer EE) - developed and commercially supported


# Helm Chart for SignServer Community

Helm chart for deploying SignServer in Kubernetes. Designed to be simple and flexible.

Welcome to SignServer – the Open Source Signing Software. Digitally sign documents, code, and timestamps while keeping your signature process and keys secure.

OSI Certified is a certification mark of the Open Source Initiative.

# Helm Chart for SignServer Enterprise

**[Documentation](https://docs.keyfactor.com/container/latest/signserver/)** for SignServer Enterprise

---

## Prerequisites

- [Kubernetes](http://kubernetes.io) v1.19+
- [Helm](https://helm.sh) v3+
- [EJBCA](https://www.ejbca.org), or another certificate authority for infrastructure and signer certificates.  

---

## Quick Start

The **SignServer Community Helm Chart** bootstraps **SignServer Community** on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

To deploy an ephemeral SignServer Community test instance using Helm:
```shell
helm install signserver-ce --set image.repository=keyfactor/signserver-ce \
    oci://repo.keyfactor.com/charts/signserver-ce --version x.y.z
```

For deployment configuration and production setup, see the [full documentation](https://docs.keyfactor.com/container/latest/signserver/get-started-with-signserver-using-kubernetes-and-h).

---

## Community Support

In our Community we welcome contributions. The Community software is open source and community supported, there is no support SLA, but a helpful best-effort Community.

* To report a problem or suggest a new feature, use the **[Issues](../../issues)** tab.
* If you want to contribute actual bug fixes or proposed enhancements, use the **[Pull requests](../../pulls)** tab.
* Ask the community for ideas: **[SignServer Discussions](https://github.com/Keyfactor/signserver-ce/discussions)**.
* Read more in our documentation: **[SignServer Documentation](https://doc.primekey.com/signserver)**.
* See release information: **[SignServer Release information](https://doc.primekey.com/signserver/signserver-release-information)**.
* Read more on the open source project website: **[SignServer website](https://www.signserver.org/)**.

## Commercial Support
Commercial support is available for **[SignServer Enterprise](https://www.keyfactor.com/platform/keyfactor-signserver-enterprise/)**.

## License
SignServer Community is licensed under the LGPL license, please see **[LICENSE](LICENSE)**.
