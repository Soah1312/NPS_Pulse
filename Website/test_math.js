import { calculateRetirement } from './src/utils/math.js';
const testUser = {
  age: 32,
  retireAge: 60,
  monthlyIncome: 85000,
  npsContribution: 5000,
  npsCorpus: 120000,
  totalSavings: 50000,
  addSavings: true,
  npsEquity: 75,
  lifestyle: 'comfortable',
  taxRegime: 'new'
}
console.log(calculateRetirement(testUser));
