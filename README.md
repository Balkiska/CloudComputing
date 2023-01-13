# CloudComputing

Controle Classe 4

User : controleclasse4@deletoilleprooutlook.onmicrosoft.com
Mdp : Glhf123!
IGNOREZ ACTIVATION MFA

Créer un dossier PRENOM-NOM sur votre Bureau (le controle se fera depuis ce dossier)
PRENOM-NOM tout en haut de votre code.

Questions :
 
1) Quels sont les avantages d'utiliser Terraform ?

2) Comment fonctionne le Tfstate ?

3) Comment invoquer des informations de ressources déjà existantes dans Terraform ?

4) Qu'est ce qu'Azure ? Que peut-on déployer sur Azure ? 

5) Citez 2 outils DevOps (en dehors de Terraform) et donnez une description très basique de ces outils et leur utilité.

6) Citez 2 droits Azure et leur utilité. 


Utilisez Commentaires, Variables, Count, For_Each, Datasources lorsque necessaire. 

1) Déployer un resource group en West Europe avec votre première lettre de prénom suivi de votre nom de famille. (toutes les ressources sont à déployer sur ce resource group)

2) Déployer un Keyvault avec tous les droits secret au groupe utilisateur "group-etudiants", vous y attacherez un private endpoint au subnet 5 (à faire après question 5).

3) Déployer un MSSQL_Server avec une règle réseau autorisant votre IP Public et la mienne (82.123.113.93).

4) Déployer une base de données sur votre SQL Server en General Purpose, Generation 5, Serverless, 4 Vcore Maximum, 30Go Disk

5) Déployer 1 vnet et 5 subnets.  

6) Déployer 1 vm Ubuntu en 20.04 LTS sur votre subnet 5 et stocker la clé SSH dans votre keyvault.

7) Déployer 2 Disks 500Go, 1To et les connecter à votre VM. 

8) Déployer 2 Storage Account sur mon resource group "bonchance", 1 en Premium, 1 en Standard.

9) Déployer 1 log Analytics, et envoyer les metrics de votre storage account Premium dessus.

10) Donnez les droits Contributor à l'utilisateur "wow@deletoilleprooutlook.onmicrosoft.com" sur votre Resource Group

11) Déployez un grafana en AZAPI et vous y connecter

Lorsque votre code est terminé, ouvrez Azure Storage Explorer puis :

- Cliquez sur le symbole "prise" à gauche
- Cliquez sur Blob Container
- Sélectionnez Shared Access Signature URL
- Collez dans Blob URL la clé suivante https://classe0.blob.core.windows.net/glhf?sp=racwli&st=2023-01-13T12:31:16Z&se=2023-01-13T20:31:16Z&sv=2021-06-08&sr=c&sig=cV1dy4qYE7NcJK%2FZEeWNGLdSbBTojGhCjz%2BmdJ%2BNttU%3D
- Une fois connecté, Uploadez votre Folder (Non Zippé)

Faites un Terraform Destroy
