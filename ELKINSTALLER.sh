echo " _______      _    _ __  __       _______ _    _ _____   _____ _____          "
echo "|__   __|/\  | |  | |  \/  |   /\|__   __| |  | |  __ \ / ____|_   _|   /\    "
echo "   | |  /  \ | |  | | \  / |  /  \  | |  | |  | | |__) | |  __  | |    /  \   "
echo "   | | / /\ \| |  | | |\/| | / /\ \ | |  | |  | |  _  /| | |_ | | |   / /\ \  "
echo "   | |/ ____ \ |__| | |  | |/ ____ \| |  | |__| | | \ \| |__| |_| |_ / ____ \ "
echo "   |_/_/    \_\____/|_|  |_/_/    \_\_|   \____/|_|  \_\\_____|_____/_/    \_\ "
echo "                                                                              "                                                                          
# Script Yazım Tarihi: 29 Aralık 2020
# Yazarlar: Bilal Teke
# Cyber Struggle
# Taumaturgıa
# ELK OTOMATİK KURULUM PROGRAMI 

echo "ELK kurulumuna hoşgeldiniz. Script çalışmak için root yetkilerine ihtiyaç duymaktadır."

[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

echo "Sistem güncellemesi yapılacaktır."

sudo apt update 
sudo apt upgrade 
sudo apt install curl
echo "-------------------------------------------------"
echo "Openjdk kuruluyor."

sudo apt-get install openjdk-8-jdk
echo "-------------------------------------------------"
echo "Anahtarlar ekleniyor."

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "-------------------------------------------------"
echo "apt-transport-https kuruluyor"
sudo apt-get install apt-transport-https -y
echo "-------------------------------------------------"
echo "Anahtarlar ekleniyor"
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

sudo apt-get update && sudo apt-get install elasticsearch && sudo apt-get install logstash && sudo apt-get install kibana
echo "-------------------------------------------------"
echo "Konfigürasyonlar tamamlanıyor."

sed -i 's/#cluster.name: my-application/cluster.name: new-elk /' /etc/elasticsearch/elasticsearch.yml
sed -i 's/#node.name: node-1/node.name: elk1/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/#http.port: 9200/http.port: 9200/' /etc/elasticsearch/elasticsearch.yml
echo "-------------------------------------------------"
echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml

systemctl start elasticsearch


if [[ $(curl -XGET http://localhost:9200/_cluster/health?pretty) ]]; then
    echo "Everything seems to be ok here."
else
    echo "Something wrong"
fi
echo "-------------------------------------------------"
sed -i 's/#server.name: "your-hostname"/server.port: "new-kibana"/' /etc/kibana/kibana.yml
sed -i 's/#server.host: "localhost"/server.host:"localhost"/' /etc/kibana/kibana.yml
sed -i 's/#server.port: 5601/server.port: 5601/' /etc/kibana/kibana.yml
sed -i 's/#elasticsearch.hosts: \["http:\/\/localhost:9200"]/elasticsearch.hosts: \["http:\/\/localhost:9200"]/' /etc/kibana/kibana.yml
echo "-------------------------------------------------"
cd /etc/logstash/conf.d
touch logstash.conf

echo "input {
 beats {
   port => 5044  
}
}filter {}output {
 elasticsearch {
  hosts => localhost
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
       }
}" > logstash.conf
echo "-------------------------------------------------"
echo "Firewall ayarları yapılıyor"
echo "UYARI: FIREWALL AYARLARI UBUNTU TEMELLİ SİSTEMLER BAZ ALINARAK OLUŞTURULMUŞTUR. EĞER FİREWALLD KULLANIYORSANIZ MANUEL OLARAK AYARLAYINIZ"


ufw allow 5044
ufw allow 9200
ufw allow 5601
echo "-------------------------------------------------"
echo "Servisler Başlatılıyor."

systemctl enable logstash
systemctl enable kibana
systemctl enable elasticsearch
systemctl start logstash
systemctl start kibana
echo "-------------------------------------------------"
echo "Sistem durumları aşağıdaki gibidir."

systemctl status logstash
systemctl status kibana
systemctl status elasticsearch
echo "-------------------------------------------------"
echo "Kurulum tamamlandı."


