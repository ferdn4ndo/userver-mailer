<?php

#
$config['imap_conn_options'] = array(
  'ssl' => array(
    'verify_peer' => true,
    // certificate is not self-signed if cafile provided
    'allow_self_signed' => false,
    // If not LetsEncrypt:
    // 'cafile'  => '/etc/ssl/certs/Your_CA_certificate.pem',
    // For Letsencrypt use the following two lines and remove the 'cafile' option above.
    'ssl_cert' => getenv('TLS_CERT_PEM_FILE'),
    'ssl_key'  => getenv('TLS_CERT_KEY_FILE'),
    // probably optional parameters
    'ciphers' => 'ALL:!ADH:!LOW:!EXP:!aNULL:+HIGH:+MEDIUM',
    'peer_name'         => getenv('TLS_PEER_NAME'),
  )
);
