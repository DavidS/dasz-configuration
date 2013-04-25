# windows pc
node 'david-pc3.dasz' {
  package { 'notepadplusplus':
    ensure   => installed,
    provider => 'chocolatey';
  }
}