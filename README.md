# Projet Fil-Rouge : Infrastructure as Code (IaC)

Ce dépôt documente l'implémentation d'une infrastructure AWS automatisée, réalisée dans le cadre de la formation "Programmation pour le Cloud". Le projet vise à transformer des processus manuels en une architecture robuste, sécurisée et reproductible.

## 1. Objectifs du projet
L'objectif est de déployer une solution de traitement d'images automatisée via le flux suivant :
1. Ingestion : Un utilisateur uploade une image dans un bucket S3 source.
2. Traitement : Une fonction AWS Lambda est déclenchée automatiquement pour renommer le fichier et le convertir en PDF.
3. Stockage : Le fichier converti est stocké dans un bucket S3 de destination.
4. Maintenance : Une mise à jour du code applicatif (handler.py) est gérée via Ansible.

## 2. Actions et choix techniques

### A. Provisioning avec Terraform
- Approche modulaire : L'infrastructure est découpée en modules réutilisables (S3, Lambda, IAM).
- Sécurité : Utilisation de "aws sts assume-role" pour éviter le stockage de clés d'accès en clair.
- Conformité : Application systématique du tag "Project = ynov-iac-2025" sur toutes les ressources.

### B. Automatisation CI/CD (GitHub Actions)
La pipeline garantit la qualité du code à chaque modification :
- Validation : terraform fmt et validate assurent la cohérence du code.
- Sécurité : Scan automatique avec Checkov pour identifier les failles.
- Optimisation financière : Analyse des coûts via Infracost.
- Qualité : Utilisation de ansible-lint pour valider les scripts Ansible.

### C. Gestion applicative avec Ansible
- Ansible intervient après le provisionnement pour gérer le cycle de vie du code applicatif (handler.py), permettant de séparer l'infrastructure de la configuration.

## 3. Guide de déploiement
1. Configuration locale : Configurez votre environnement pour utiliser aws sts assume-role.
2. Initialisation : Clonez le dépôt et initialisez Terraform.
3. Planification : Exécutez "terraform plan" pour visualiser les changements.
4. Déploiement : Appliquez les changements avec "terraform apply".
