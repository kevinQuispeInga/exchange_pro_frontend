const SYMBOLS = {
  PEN: 'S/',
  USD: '$',
  EUR: '\u20AC',
  JPY: '\u00A5',
  GBP: '\u00A3'
}

const ID_TO_CODE = {
  1: 'PEN',
  2: 'USD',
  3: 'EUR',
  4: 'JPY',
  5: 'GBP'
}

export function currencySymbol(monedaId, monedaCode) {
  if (monedaCode && SYMBOLS[monedaCode]) return SYMBOLS[monedaCode]
  const code = ID_TO_CODE[Number(monedaId)]
  if (code && SYMBOLS[code]) return SYMBOLS[code]
  return 'S/'
}

export function formatNumber(val) {
  if (val == null) return '0.00'
  return Number(val).toLocaleString('es-PE', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

export function formatCurrency(val, monedaId, monedaCode) {
  const sym = currencySymbol(monedaId, monedaCode)
  return `${sym} ${formatNumber(val)}`
}
