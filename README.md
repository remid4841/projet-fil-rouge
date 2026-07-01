# Projet Fil-Rouge — Infrastructure as Code (AWS)

**Formation** : Programmation pour le Cloud — Ynov Bordeaux Campus
**Stack** : Terraform · Ansible · AWS (S3, Lambda, IAM) · GitHub Actions

## 1. Objectif

Déployer une infrastructure AWS automatisée qui convertit des images en PDF à la volée :

1. Un utilisateur dépose une image dans un bucket S3 **source**.
2. Une fonction **Lambda** est déclenchée automatiquement par l'événement S3.
3. La Lambda convertit l'image en PDF et la renomme.
4. Le fichier PDF est déposé dans un bucket S3 **destination**.
5. Le code applicatif de la Lambda (`handler.py`) est mis à jour via **Ansible**, indépendamment du provisioning Terraform.

## 2. Architecture

```
┌─────────────┐        upload image        ┌───────────────────────┐
│ Utilisateur  │ ──────────────────────────▶ │  S3 bucket SOURCE     │
└─────────────┘                              │  ynov-iac-2025-source │
                                              └───────────┬───────────┘
                                                           │ event: s3:ObjectCreated:*
                                                           ▼
                                              ┌───────────────────────┐
                                              │  AWS Lambda            │
                                              │  image_to_pdf_processor│
                                              │  (Python 3.11 + Pillow)│
                                              │                        │
                                              │  handler.py :          │
                                              │  1. download image     │
                                              │  2. convert → PDF      │
                                              │  3. rename              │
                                              │  4. upload PDF          │
                                              └───────────┬───────────┘
                                                           │ upload PDF
                                                           ▼
                                              ┌───────────────────────┐
                                              │  S3 bucket DESTINATION │
                                              │  ynov-iac-2025-dest    │
                                              └───────────────────────┘
```

### Provisioning (Terraform)

```
terraform/
├── main.tf                 # assemble les modules
├── providers.tf            # provider AWS + assume_role + default_tags
├── variables.tf
├── terraform.tfvars        # ARN du rôle IAM restreint
└── modules/
    ├── s3/                 # buckets source + destination
    └── lambda/              # fonction Lambda, rôle IAM, permission S3→Lambda, notification
```

- **Modules réutilisables** : `modules/s3` et `modules/lambda`, appelés depuis `main.tf`.
- **Sécurité des accès** : le provider AWS utilise `assume_role` — les clés d'accès fournies par l'intervenant servent uniquement à endosser un rôle IAM restreint (`role_etudiants`), jamais utilisées directement sur les ressources.
- **Conformité** : tag `Project = ynov-iac-2025` appliqué automatiquement à toutes les ressources via `default_tags` dans le provider (policy IAM du compte refuse toute ressource non taguée).

### Automatisation applicative (Ansible)

```
ansible/
├── requirements.yml         # collections : amazon.aws, community.aws, community.general
└── update_lambda.yaml       # playbook : package les dépendances + met à jour le code de la Lambda
```

Séparation des responsabilités : **Terraform** provisionne l'infrastructure (buckets, rôle IAM, Lambda, notification), **Ansible** gère le cycle de vie du code applicatif du handler — permet de déployer un correctif du handler sans repasser par un `terraform apply` complet.

### Pipeline CI/CD (GitHub Actions)

Déclenché à chaque push, le pipeline enchaîne :

| Étape | Outil | Rôle |
|---|---|---|
| `fmt` / `validate` | Terraform | Cohérence et validité syntaxique du code |
| `plan` | Terraform | Prévisualisation des changements |
| Scan sécurité | Checkov | Détection de mauvaises pratiques (IAM trop permissif, secrets en dur, etc.) |
| Estimation coûts | Infracost | Chiffrage du coût mensuel de l'infra |
| Lint | ansible-lint | Validation syntaxique des playbooks |
| `apply` | Terraform | Déploiement effectif des ressources |
| Mise à jour handler | Ansible | Packaging + déploiement du code applicatif *(en cours de finalisation)* |

## 3. Fonctionnement détaillé

1. **Déclenchement** : une notification `aws_s3_bucket_notification` sur le bucket source écoute l'événement `s3:ObjectCreated:*` et invoque la Lambda. Une `aws_lambda_permission` autorise explicitement le service S3 à invoquer la fonction (source restreinte à ce bucket).
2. **Traitement** (`handler.py`) :
   - téléchargement de l'objet uploadé dans `/tmp` ;
   - ouverture avec **Pillow** (`PIL.Image`), conversion en RGB puis sauvegarde au format PDF ;
   - le nom de fichier est conservé mais l'extension devient `.pdf` ;
   - upload du PDF vers le bucket destination (variable d'environnement `DEST_BUCKET`).
3. **Permissions** : un rôle IAM dédié à la Lambda (`lambda_s3_processor_role`) porte une policy restreinte en lecture/écriture sur les deux buckets uniquement — pas de `*` ni de privilèges d'administration (validé par Checkov, 0 échec sur les checks IAM).

## 4. État d'avancement

| Composant | État |
|---|---|
| Provisioning Terraform (S3 + Lambda + IAM) | ✅ Fonctionnel, déployé avec succès |
| Déclenchement automatique S3 → Lambda | ✅ Fonctionnel |
| Sécurité (`assume_role`, tags, policies restreintes) | ✅ Conforme au sujet |
| Pipeline CI/CD (fmt/validate/plan/Checkov/Infracost/lint) | ✅ Vert |
| Logique métier du handler (conversion image → PDF) | ✅ Codée |
| Packaging des dépendances Python (Pillow) dans le déploiement Lambda | ⚠️ En cours — Pillow n'est pas encore inclus dans le zip de déploiement |
| Étape Ansible de mise à jour du handler branchée dans la CI | ⚠️ En cours — le playbook existe et est linté, l'invocation dans le pipeline reste à finaliser |
| Preuves d'exécution AWS CLI (test end-to-end) | ⏳ À réaliser |

## 5. Déploiement local

```bash
# Provisioning infra
cd terraform
terraform init
terraform plan
terraform apply

# Mise à jour du code applicatif de la Lambda
cd ../ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook update_lambda.yaml
```

## 6. Technologies

| Outil | Rôle | Version |
|---|---|---|
| Terraform | Provisioning S3 + Lambda (modules réutilisables) | ≥ 1.6 |
| AWS CLI v2 | Vérification / interaction AWS via assume-role | ≥ 2.x |
| Ansible | Mise à jour du code Lambda (`handler.py`) | collections `amazon.aws`, `community.aws` |
| GitHub Actions | Pipeline CI/CD | `fmt · validate · plan · Checkov · Infracost · ansible-lint` |
| Python 3.11 + Pillow | Runtime Lambda + conversion image → PDF | — |
