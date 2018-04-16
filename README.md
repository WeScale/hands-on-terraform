# Hands on Terraform

Cet ensemble d'exercices a été initié pour une session donnée à Devoxx 2018. Pour dérouler ce hands-on
vous aurez besoin :

* d'un compte AWS et de vos clés d'API AWS
* *Sous Windows*: d'installer [Git For Windows](https://gitforwindows.org/) et de lancer Git Bash pour lancer les commandes listées
dans ce tutoriel.
* du binaire Terraform ([installer](https://www.terraform.io/downloads.html))
* un éditeur de code. Si vous n'avez pas de préférence, nous vous conseillons [Pycharm](https://www.jetbrains.com/pycharm/download/#section=linux)
additionné du plugin [Terraform/HCL](https://plugins.jetbrains.com/plugin/7808-hashicorp-terraform--hcl-language-support)

## Step 0 : Provider AWS

Il s'agit de valider que vous avez bien accès à votre compte AWS via vos clés d'API.

* Suivez le [guide de configuration du provider](https://www.terraform.io/docs/providers/aws/). Nous vous conseillons de prendre
l'option `Environment variables` puisque c'est celle que nous avons prise. Les autres risquent de vous forcer à éditer du
code à chaque étape.

* Placez vous dans le répertoire `step-0`

* Lancez les commandes:
```
terraform init
terraform plan
terraform apply
```

Vous devriez voir une sortie identique à celle-ci :
```
data.aws_caller_identity.current: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

account_id = ...
caller_arn = ...
caller_user = ...
```

Si c'est le cas, Terraform arrive à s'authentifier auprès d'AWS. Bravo.

## Step 1 : Réseau

Nous allons maintenant déployer le réseau nécessaire pour notre projet.

* Placez vous dans le répertoire `step-1`

* Parcourez attentivement et effectuez les TODO contenus dans les fichiers :

  * `providers.tf`
  * `variables.tf`

* Si vous faites les choses bien vous devriez être en mesure de lancer successivement:

```
terraform init
terraform plan
terraform apply
```

Si c'est le cas. Bravo, vous avez maintenant un espace réseau dans lequel déployer des instances!

## Step 2 : Première instance

Nous allons passer aux choses sérieuses et déployer notre prenier serveur EC2. Pour cela il va falloir créer une clé rsa
pour s'y connecter.

* Placez vous à la racine du projet et lancez :
```
ssh-keygen -t rsa -b 2048 -N "" -f devoxx.key && chmod 600 devoxx.key
```

* Parcourez les mentions TODO dans le code terraform avec pour objectif de faire passer:

```
terraform init
terraform plan
terraform apply
```

Si vous passez cet exercice avec succès, vous devriez pouvoir vous connecter en ssh à votre instance avec la commande:
```
# Lancer depuis la racine du projet
ssh $(terraform output -state=step-2/terraform.tfstate instance_ip) -l centos -i devoxx.key
```

## Step 3 : Load balancing

enregistrer instance step-2 et une nouvelle dans un ALB
Problème d'instance unhealthy si l'enregistrement dans le target group se fait avant la disponibilité du port HTTP. Comment régler cela ? Comment éviter
la reproduction du problème

## Step 4 : Configuration du Backend

Ajouter le fichier backend.tf dans votre projet pour configurer le stockage des tfstate dans un bucket s3.    
Vous devez faire un ``` terraform init ``` pour configurer celui-ci.

## Step 5 : Autoscaling & ALB

* Détruire les step 3 et step 2 grâce à la commande (en vous plaçant dans les bon répertoires bien sûr) :
```
terraform destroy
```

* Placez vous dans le répertoire step-5 et déroulez les TODO présents pour arriver à appliquer le workflow standard init-plan-apply

## Step 6 : Consolider

* Détruire chaque step en ordre inverse des déploiements.
* Reprendre tous les fichiers `variables.tf` et en supprimer les valeurs par défaut.
* Regrouper les valeurs dans un fichier tfvars â la racine du projet et le passer en ligne de commande pour redéployer tous
les steps.

Vous trouverez de l'aide ici :

* [Terraform doc - assigning variables](https://www.terraform.io/intro/getting-started/variables.html#from-a-file)