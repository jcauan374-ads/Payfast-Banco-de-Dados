const transactions = [
  { id: 'TX-0001', origin: 'Ana Souza', destination: 'Bruno Lima', type: 'PIX', value: 150.00, status: 'CONCLUIDA' },
  { id: 'TX-0002', origin: 'Bruno Lima', destination: 'Carla Mendes', type: 'PIX', value: 275.50, status: 'CONCLUIDA' },
  { id: 'TX-0003', origin: 'Carla Mendes', destination: 'Diego Alves', type: 'PIX', value: 1000.00, status: 'PENDENTE' },
  { id: 'TX-0004', origin: 'Diego Alves', destination: 'Elaine Rocha', type: 'PIX', value: 80.00, status: 'FALHA' },
  { id: 'TX-0005', origin: 'Elaine Rocha', destination: 'Ana Souza', type: 'PIX', value: 320.75, status: 'ESTORNADA' },
];

const statusLabel = { CONCLUIDA: 'Concluída', PENDENTE: 'Pendente', FALHA: 'Falha', ESTORNADA: 'Estornada' };
const money = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' });
const tbody = document.getElementById('transactions-body');
const filter = document.getElementById('status-filter');
const count = document.getElementById('transaction-count');

function renderTransactions() {
  const selected = filter.value;
  const visible = selected === 'TODAS' ? transactions : transactions.filter((item) => item.status === selected);
  tbody.innerHTML = visible.map((item) => `
    <tr>
      <td>${item.id}</td>
      <td>${item.origin}<span class="account-arrow">→</span>${item.destination}</td>
      <td>${item.type}</td>
      <td>${money.format(item.value)}</td>
      <td><span class="status status-${item.status.toLowerCase()}">${statusLabel[item.status]}</span></td>
    </tr>`).join('');
  count.textContent = `${visible.length} ${visible.length === 1 ? 'registro' : 'registros'}`;
}

filter.addEventListener('change', renderTransactions);
renderTransactions();

document.querySelectorAll('nav a[href^="#"]').forEach((link) => link.addEventListener('click', () => {
  document.querySelectorAll('nav a').forEach((item) => item.classList.remove('active'));
  link.classList.add('active');
}));
