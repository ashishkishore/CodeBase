class Tab:

    menu={
        'red_wine':500,
        'signature_whisky':825,
        'bp_whisky':930,
        'old_monk_rum':450,
        'smirnoff_vodka':1025,
        'beer': 200,
        'chicken':400,
        'fish':625,
        'pron':550,
        'paneer':350,
        'salad':75,
        'peenut_masala':100,
        'king':150
    }

    def __init__(self):
        self.total=0
        self.item=[ ]

    def add(self,item):
        self.item.append(item)
        self.total += self.menu[item]

    def print_bill(self,tax,service):
        tax_total=(tax/100)*self.total
        service_total= (service/100)*self.total
        total = self.total + tax_total + service_total
        for item in self.item:
            print(f'{item:20} Rs.{self.menu[item]}')
        print(f'{"Tax":20} Rs.{tax_total+service_total}')
        print(f'{"Total":20} Rs.{total}')